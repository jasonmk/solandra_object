module SolandraObject
  module SearchMethods
    attr_accessor :group_values, :order_values, :where_values, :where_not_values, :fulltext_values, :search_values
    attr_accessor :offset_value, :page_value, :per_page_value, :reverse_order_value, :query_parser_value
    # Used to extend a scope with additional methods, either through 
    # a module or a block provided
    #
    # The object returned is a relation which can be further extended
    def extending(*modules)
      modules << Module.new(&Proc.new) if block_given?

      return self if modules.empty?

      relation = clone
      relation.send(:apply_modules, modules.flatten)
      relation
    end
    
    # Limit a single page to +value+ records
    #
    #   Model.limit(1)
    #   Model.per_page(50)
    #
    # Note that ALL SolandraObject searches are paginated.  By default, page is
    # set to one and per_page is set to 30.  This can be overridden on a per-model
    # basis by overriding the default_page_size class method in your model:
    #
    #   class Model < SolandraObject::Base
    #     def self.default_page_size
    #       50
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
    def order(attr)
      return self if attr.blank?

      clone.tap do |r|
        order_by = attr.is_a?(Hash) ? attr.dup : {attr => :asc}
        
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
    def query_parser(attr)
      return self if attr.blank?
      
      clone.tap do |r|
        r.query_parser_value = attr
      end
    end
    
    # Specifies restrictions (scoping) on the result set. Expects a hash
    # in the form +attribute => value+.
    #
    #   Model.where(:group_id => '1234', :active => 'Y')
    def where(attr)
      return self if attr.blank?
      
      clone.tap do |r|
        r.where_values << attr
      end
    end
    
    # Specifies restrictions (scoping) that should not match the result set.
    # Expects a hash in the form +attribute => value+.
    #
    #   Model.where_not(:group_id => '1234', :active => 'N')
    def where_not(attr)
      return self if attr.blank?
      
      clone.tap do |r|
        r.where_not_values << attr
      end
    end
    
    # Specifies a full text search string to be processed by SOLR
    #
    #   Model.fulltext("john smith")
    def fulltext(attr)
      return self if attr.blank?
      
      clone.tap do |r|
        r.fulltext_values << attr
      end
    end
    
    protected
      def find_by_attributes(match, attributes, *args)
        conditions = Hash[attributes.map {|a| [a, args[attributes.index(a)]]}]
        result = where(conditions).send(match.finder)
        
        if match.blank? && result.blank?
          raise RecordNotFound, "Couldn't find #{klass.name} with #{conditions.to_a.collect {|p| p.join('=')}.join(', ')}"
        else
          yield(result) if block_given?
          result
        end
      end
  end
end