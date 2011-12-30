module SolandraObject
  class Relation
    include SearchMethods
    attr_reader :klass, :column_family, :loaded
    alias :loaded? :loaded
    
    MULTI_VALUE_METHODS = [:group, :order, :where, :where_not, :fulltext, :search]
    SINGLE_VALUE_METHODS = [:offset, :page, :per_page, :reverse_order, :query_parser]
    
    def initialize(klass, column_family)
      @klass, @column_family = klass, column_family
      @loaded = false
      @results = []
      @default_scoped = false
      
      SINGLE_VALUE_METHODS.each {|v| instance_variable_set(:"@#{v}_value", nil)}
      MULTI_VALUE_METHODS.each {|v| instance_variable_set(:"@#{v}_values", [])}
      @per_page = @klass.default_page_size
      @page = 1
      @offset = 0
      @extensions = []
      @create_with_value = {}
      apply_default_scope
    end
    
    # Returns true if the two relations have the same query parameters
    def ==(other)
      case other
      when Relation
        other.sunspot_search.query.to_params == sunspot_search.query.to_params
      when Array
        to_a == other
      end
    end
    
    # Returns true if there are any results given the current criteria
    def any?
      if block_given?
        to_a.any? { |*block_args| yield(*block_args) }
      else
        !empty?
      end
    end
    alias :exists? :any?
    
    # Returns the total number of entries that match the given search.
    # This means the total number of matches regardless of page size.
    # Compare with +size+.
    def count
      if loaded?
        @results.total_entries
      else
        limit(1).to_a.total_entries
      end
    end
    
    # Gets a default scope with no conditions or search attributes set.
    def default_scope
      clone.tap do |r|
        SINGLE_VALUE_METHODS.each {|v| r.instance_variable_set(:"@#{v}_value", nil)}
        MULTI_VALUE_METHODS.each {|v| r.instance_variable_set(:"@#{v}_values", [])}
        apply_default_scope
      end
    end
    
    # Returns the first record from the result set if it's already loaded.
    # Otherwise, runs the search with a limit of 1 and returns that.
    def first
      @first ||= if loaded?
        @results.first
      else
        limit(1).to_a.first
      end
    end
    
    # Returns true if there are no results given the current criteria
    def empty?
      return @results.empty? if loaded?
      
      c = count
      c.respond_to?(:zero?) ? c.zero? : c.empty?
    end
    
    # Returns true if there are multiple results given the current criteria
    def many?
      if block_given?
        to_a.many? { |*block_args| yield(*block_args) }
      else
        count > 1
      end
    end
    
    # Constructs a new instance of the class this relation points to
    def new(*args, &block)
      @klass.new(*args, &block)
    end
    
    # Reloads the results from Solr
    def reload
      reset
      to_a
      self
    end
    
    # Empties out the current results.  The next call to to_a
    # will re-run the query.
    def reset
      @loaded = @first = nil
      @results = []
    end
    
    def initialize_copy(other) #:nodoc:
      reset
      @search = nil
    end
    
    def clone
      dup.tap do |r|
        MULTI_VALUE_METHODS.each do |m|
          if m == :search
            # Proc's can't be dumped, but a regular clone should be all right since they aren't deep memory structures
            r.search_values = self.search_values.clone
          else
            r.send("#{m}_values=", Marshal.load(Marshal.dump(self.send("#{m}_values"))))
          end
        end
        SINGLE_VALUE_METHODS.each do |m|
          r.send("#{m}_value=", Marshal.load(Marshal.dump(self.send("#{m}_value"))))
        end
      end
    end
    
    # Returns the size of the total result set for the given criteria
    # NOTE that this takes pagination into account so will only return
    # the number of results in the current page.  SolandraObject queries
    # default to a page size of 30
    def size
      return @results.size if loaded?
      total_entries = count
      total_entries > page_size ? page_size : total_entries
    end
    
    # Returns the total number of pages required to display the results
    # given the current page size.  Used by will_paginate.
    def total_pages
      (count / page_size.to_f).ceil
    end
    
    # Actually executes the query if not already executed.
    # Returns a standard array thus no more methods may be chained.
    def to_a
      return @results if loaded?
      @results = sunspot_search.execute.results
      @loaded = true
      @results
    end
    alias :all :to_a
    alias :results :to_a
    
    def respond_to?(method, include_private = false) #:nodoc:
      sunspot_search.respond_to?(method, include_private)   ||
        Array.method_defined?(method)                       ||
        @klass.respond_to?(method, include_private)         ||
        super
    end
    
    # Returns the actual Sunspot search object
    def sunspot_search
      return @search if @search
      @search = Sunspot.new_search(@klass)
      @where_values.each do |wv|
        wv.each do |k,v|
          @search.build { with k, v }
        end
      end
      
      @where_not_values.each do |wnv|
        wnv.each do |k,v|
          @search.build { without k, v }
        end
      end
      
      @order_values.each do |ov|
        ov.each do |k,v|
          if(@reverse_order_value)
            @search.build { order_by k, (v == :asc ? :desc : :asc) }
          else
            @search.build { order_by k, v }
          end
        end
      end
      
      @group_values.each do |gv|
        @search.build { group gv }
      end
      
      @fulltext_values.each do |ftv|
        @search.build { fulltext ftv }
      end
      
      # We have to put these in local variables because the block doesn't
      # get access to our instance variables
      pv, ppv, ov = @page_value, @per_page_value, @offset_value
      @search.build { paginate :page => pv, :per_page => ppv, :offset => ov }
      
      qpv = @query_parser_value
      
      if qpv
        @search.build do
          adjust_solr_params do |params|
            params[:defType] = qpv
          end
        end
      else
        @search.build do
          adjust_solr_params do |params|
            params.delete :defType
          end
        end
      end
      
      @search_values.each do |sv|
        @search.build(&sv)
      end
      @search
    end
    
    protected
    
      def page_size
        sunspot_search.query.instance_variable_get(:@pagination).per_page
      end
      
      def method_missing(method, *args, &block)
        if Array.method_defined?(method)
          to_a.send(method, *args, &block)
        elsif @klass.respond_to?(method)
          @klass.send(method, *args, &block)
        elsif sunspot_search.respond_to?(method)
          sunspot_search.send(method, *args, &block)
        else
          super
        end
      end
  end
end