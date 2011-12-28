module SolandraObject
  module SearchMethods
    
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
    def limit(value)
      clone.tap do |r|
        r.sunspot_search.query.instance_variable_get(:@pagination).per_page = value
      end
    end
    alias :per_page :limit
    
    # Sets an offset into the result set to start looking at
    def offset(value)
      clone.tap do |r|
        r.sunspot_search.query.instance_variable_get(:@pagination).offset = value
      end
    end
    
    # Sets the page number to retrieve
    def page(value)
      clone.tap do |r|
        r.sunspot_search.query.instance_variable_get(:@pagination).page = value
      end
    end
    
    # Group results by one or more attributes only returning the top result
    # for each group.
    def group(*attrs)
      return self if attrs.empty?
      
      clone.tap do |r|
        r.sunspot_search.build { group attrs }
      end
    end
    
    # Orders the result set by a particular attribute.  Note that text fields
    # may not be used for ordering as they are tokenized.  Valid candidates
    # are fields of type +string+, +integer+, +long+, +float+, +double+, and
    # +time+.  In addition, the word +score+ can be used to sort on the 
    # relevance rating returned by Solr.  The default direction is ascending
    # but may be reversed by passing +:desc+ as the second parameter.
    def order(attr, direction = :asc)
      return self if attr.blank?
      
      clone.tap do |r|
        r.sunspot_search.build { order_by attr, direction }
      end
    end
    
    # Direct access to Sunspot search method.
    #
    #   relation.search do
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
        r.sunspot_search.build(&block)
      end
    end
    
    def reverse_order()
      # TODO: Implement this
    end
    
    # Specifies restrictions (scoping) on the result set.
    #
    # +attr+ is the field name to match against.  For full-text searches,
    #        you can also use +:all_fields+ to search across all text fields.
    # +value+ can be a scalar, range, or array of scalars.
    #
    # +opts+ is a hash of the following options:
    #   +:fulltext+: if set to true, performs a fulltext search instead of a
    #                standard equality search.  For this to work, attr must
    #                be set to a text field (or +:all_fields+).  The following
    #                options will be ignored if this is set to true:
    #                +:negate+, +:greater_than+, and +:less_than+
    #   +:highlight+: if doing a fulltext search, this can be an array of fields
    #                 to return highlighting information on.
    #                 Note that for this to work the field must be +:stored+.
    #   +:use_dismax+: If doing a fulltext search, this instructs SOLR to use
    #                  the DisMax query parser to interpret the query.
    #   +:negate+: if set to true, negates a condition
    #   +:greater_than+: if set to true requires +attr+ to be greater than +value+.
    #                    value must be a scalar in this case.
    #   +:less_than+: if set to true requires +attr+ to be less than +value+.
    #                 value must be a scalar in this case.
    def where(attr, value, opts = {})
      relation = clone
      with = opts[:negate] ? :without : :with
      if(opts[:fulltext])
        relation.sunspot_search.build do 
          fulltext value do
            fields(attr) unless attr == :all_fields
            highlight opts[:highlight] if opts[:highlight]
          end
          unless opts[:use_dismax]
            adjust_solr_params do |params|
              params.delete :defType
            end
          end
        end
      else
        relation.sunspot_search.build do
          if(opts[:greater_than])
            send(with, attr).greater_than(value)
          elsif(opts[:less_than])
            send(with, attr).less_than(value)
          else
            send(with, attr, value)
          end
        end
      end
      relation
    end
    
    def fulltext(query, opts = {}, attr = :all_fields)
      opts = opts.merge :fulltext => true
      where(attr, query, opts)
    end
  end
end