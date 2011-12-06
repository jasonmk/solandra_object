module SolandraObject
  class Relation
    include SearchMethods
    attr_reader :klass, :column_family, :loaded?
    
    def initialize(klass, column_family)
      @klass, @column_family = klass, column_family
      @loaded = false
      @results = []
    end
    
    # Returns true if the two relations have the same query parameters
    def ==(other)
      self.search.query.to_params == other.search.query.to_params
    end
    
    # Returns true if there are any results given the current criteria
    # Aliased as +exists?+
    def any?
      if block_given?
        to_a.any? { |*block_args| yield(*block_args) }
      else
        !empty?
      end
    end
    alias :exists? :any?
    
    def count
      limit(1).to_a.total_entries
    end
    
    def first
      if loaded?
        @records.first
      else
        @first ||= limit(1).to_a[0]
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
        @limit_value ? to_a.many? : size > 1
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
    
    def initialize_copy
      reset
    end
    
    def clone
      relation = dup
      relation.instance_variable_set(:@search, @search.clone) if @search
      relation
    end
    
    # Returns the size of the total result set for the given criteria
    # NOTE that this takes pagination into account so will only return
    # the number of results in the current page.  SolandraObject queries
    # default to a page size of 30
    def size
      loaded? ? @results.size : count
    end
    
    # Aliased as +all+.  Actually executes the query if not already executed.
    # Returns a standard array thus no more methods may be chained.
    def to_a
      return @results if loaded?
      @results = sunspot_search.execute.results
      @loaded = true
      @results
    end
    alias :all :to_a
    
    def respond_to?(method, include_private = false)
      sunspot_search.respond_to?(method, include_private)   ||
        Array.method_defined?(method)                       ||
        @klass.respond_to?(method, include_private)         ||
        super
    end
    
    # Returns the actual Sunspot search object
    def sunspot_search
      @search ||= Sunspot.new_search(@klass)
    end
    
    protected
      def method_missing(method, *args, &block)
        if Array.method_defined?(method)
          to_a.send(method, *args, &block)
        elsif @klass.respond_to?(method)
          @klass.send(method, *args, &block)
        elsif sunspot_search.repond_to?(method)
          sunspot_search.send(method, *args, &block)
        else
          super
        end
      end
  end
end