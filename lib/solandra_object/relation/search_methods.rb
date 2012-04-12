module SolandraObject
  module SearchMethods
    # Used to extend a scope with additional methods, either through 
    # a module or a block provided
    #
    # The object returned is a relation which can be further extended
    def extending(*modules)
      modules << Module.new(&Proc.new) if block_given?

      return self if modules.empty?

      clone.tap do |r|
        r.send(:apply_modules, modules.flatten)
      end
    end
    
    # Limit a single page to +value+ records
    #
    #   Model.limit(1)
    #   Model.per_page(50)
    #
    # Normally SolandraObject searches are paginated at a really high number
    # so as to effectively disable pagination.  However, you can cause
    # all requests to be paginated on a per-model basis by overriding the
    # +default_page_size+ class method in your model:
    #
    #   class Model < SolandraObject::Base
    #     def self.default_page_size
    #       30
    #     end
    #   end
    def limit(value)
      clone.tap do |r|
        r.per_page_value = value
      end
    end
    alias :per_page :limit
    
    # Sets an offset into the result set to start looking from
    #
    #   Model.offset(1000)
    def offset(value)
      clone.tap do |r|
        r.offset_value = value
      end
    end
    
    # Sets the page number to retrieve
    #
    #   Model.page(2)
    def page(value)
      clone.tap do |r|
        r.page_value = value
      end
    end
    
    # WillPaginate compatible method for paginating
    #
    #   Model.paginate(:page => 2, :per_page => 10)
    def paginate(options = {})
      options = options.reverse_merge({:page => 1, :per_page => 30})
      clone.tap do |r|
        r.page_value = options[:page]
        r.per_page_value = options[:per_page]
      end
    end
    
    # Group results by one or more attributes only returning the top result
    # for each group.
    #
    #   Model.group(:program_id)
    def group(*attrs)
      return self if attrs.blank?
      
      clone.tap do |r|
        r.group_values += args.flatten
      end
    end
    
    # Orders the result set by a particular attribute.  Note that text fields
    # may not be used for ordering as they are tokenized.  Valid candidates
    # are fields of type +string+, +integer+, +long+, +float+, +double+, and
    # +time+.  In addition, the symbol +:score+ can be used to sort on the 
    # relevance rating returned by Solr.  The default direction is ascending
    # but may be reversed by passing a hash where the field is the key and
    # the value is :desc
    #
    #   Model.order(:name)
    #   Model.order(:name => :desc)
    def order(attribute)
      return self if attribute.blank?

      clone.tap do |r|
        order_by = attribute.is_a?(Hash) ? attribute.dup : {attribute => :asc}
        
        r.order_values << order_by 
      end
    end
    
    # Direct access to Sunspot search method.
    #
    #   Model.search do
    #     fulltext 'best pizza'
    # 
    #     with :blog_id, 1
    #     with(:published_at).less_than Time.now
    #     order_by :published_at, :desc
    #     paginate :page => 2, :per_page => 15
    #     facet :category_ids, :author_id
    #   end
    #
    # It's important to note that this will still be in the context of
    # any other criteria you have already specified.
    def search(&block)
      clone.tap do |r|
        r.search_values << block
      end
    end
    
    # Reverses the order of the results
    # 
    #   Model.order(:name).reverse_order
    #     is equivalent to
    #   Model.order(:name => :desc)
    #
    #   Model.order(:name).reverse_order.reverse_order
    #     is equivalent to
    #   Model.order(:name => :asc)
    def reverse_order
      clone.tap do |r|
        r.reverse_order_value == !r.reverse_order_value
      end
    end
    
    # By default, SolandraObject uses the LuceneQueryParser.  Note that this
    # is a change from the underlying Sunspot gem.  Sunspot defaults to the
    # +disMax+ query parser.  If you want to use that, then pass that in here.
    #
    # *This only applies to fulltext queries*
    #
    #   Model.query_parser('disMax').fulltext("john smith")
    def query_parser(attribute)
      return self if attribute.blank?
      
      clone.tap do |r|
        r.query_parser_value = attribute
      end
    end
    
    # By default, SolandraObject will try to pick the right method of performing
    # a search.  You can use this method to force it to make the query via SOLR.
    #
    # NOTE that the time between when a record is placed into Cassandra and when
    # it becomes available in SOLR is not guaranteed to be insignificant.  It's
    # very possible to insert a new record and not find it when immediately doing
    # a SOLR search for it.
    def with_solr
      clone.tap do |r|
        r.use_solr_value = true
      end
    end
    
    # By default, SolandraObject will try to pick the right method of performing
    # a search.  You can use this method to force it to make the query via
    # cassandra.
    #
    # NOTE that this method assumes that you have all the proper secondary indexes
    # in place before you attempt to use it.  If not, you will get an error. 
    def with_cassandra
      clone.tap do |r|
        r.use_solr_value = false
      end
    end
    
    # Specifies restrictions (scoping) on the result set. Expects a hash
    # in the form +attribute => value+ for equality comparisons.
    #
    #   Model.where(:group_id => '1234', :active => 'Y')
    #
    # The value of the comparison does not need to be a scalar.  For example:
    #
    #   Model.where(:name => ["Bob", "Tom", "Sally"])
    #   Model.where(:age => 18..65)
    #
    # Inequality comparisons such as greater_than and less_than are
    # specified via chaining:
    #
    #   Model.where(:created_at).greater_than(1.day.ago)
    #   Model.where(:age).less_than(65)
    def where(attribute)
      return self if attribute.blank?
      
      if attribute.is_a?(Symbol)
        WhereProxy.new(self, attribute)
      else
        clone.tap do |r|
          r.where_values << attribute
        end
      end
    end
    
    # Specifies restrictions (scoping) that should not match the result set.
    # Expects a hash in the form +attribute => value+.
    #
    #   Model.where_not(:group_id => '1234', :active => 'N')
    def where_not(attribute)
      return self if attribute.blank?
      
      clone.tap do |r|
        r.where_not_values << attribute
      end
    end
    
    # Specifies a full text search string to be processed by SOLR
    #
    #   Model.fulltext("john smith")
    #
    # You can also pass in an options hash with the following options:
    #
    #  * :fields => list of fields to search instead of the default of all fields
    #  * :highlight => List of fields to retrieve highlights for.  Note that highlighted fields *must* be +:stored+
    #
    #   Model.fulltext("john smith", :fields => [:title])
    #   Model.fulltext("john smith", :hightlight => [:body])
    def fulltext(query, opts = {})
      return self if query.blank?
      
      opts[:query] = query
      
      clone.tap do |r|
        r.fulltext_values << opts
      end
    end
    
    # See documentation for +where+
    def less_than(value)
      raise ArgumentError, "#less_than can only be called after an appropriate where call. e.g. where(:created_at).less_than(1.day.ago)"
    end
    
    # See documentation for +where+
    def greater_than(value)
      raise ArgumentError, "#greater_than can only be called after an appropriate where call. e.g. where(:created_at).greater_than(1.day.ago)"
    end
    
    protected
      def find_by_attributes(match, attributes, *args) #:nodoc:
        conditions = Hash[attributes.map {|a| [a, args[attributes.index(a)]]}]
        result = where(conditions).send(match.finder)
        
        if match.blank? && result.blank?
          raise RecordNotFound, "Couldn't find #{klass.name} with #{conditions.to_a.collect {|p| p.join('=')}.join(', ')}"
        else
          yield(result) if block_given?
          result
        end
      end
    
    class WhereProxy #:nodoc:
      def initialize(relation, attribute) #:nodoc:
        @relation, @attribute = relation, attribute
      end
      
      def equal_to(value) #:nodoc:
        @relation.clone.tap do |r|
          r.where_values << {@attribute => value}
        end
      end
      
      def greater_than(value) #:nodoc:
        @relation.clone.tap do |r|
          r.greater_than_values << {@attribute => value}
        end
      end
      
      def less_than(value) #:nodoc:
        @relation.clone.tap do |r|
          r.less_than_values << {@attribute => value}
        end
      end
    end
  end
end