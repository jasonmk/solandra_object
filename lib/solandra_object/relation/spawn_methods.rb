module SolandraObject
  module SpawnMethods
    def scoped
      self
    end
    
    def merge(r)
      return self unless r
      return to_a & r if r.is_a?(Array)
      
      merged_relation = clone
      merged_query = merged_relation.sunspot_search.query
      incoming_query = r.sunspot_search.query
      
      
    end
    
    VALID_FIND_OPTIONS = [:conditions, :limit, :offset, :order, :group, :page, :per_page]
    def apply_finder_options(options)
      relation = clone
      return relation unless options
      
      options.assert_valid_keys(VALID_FIND_OPTIONS)
      finders = options.dup
      finders.delete_if { |key, value| value.nil? }
      
      ([:group, :order, :limit, :offset, :page, :per_page] & finders.keys).each do |finder|
        relation = relation.send(finder, finders[finder])
      end
      
      relation.where(finders[:conditions]) if options.has_key?(:conditions)
      
      relation
    end
  end
end