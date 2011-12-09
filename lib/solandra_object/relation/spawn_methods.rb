module SolandraObject
  module SpawnMethods
    def merge(r)
      return self unless r
      return to_a & r if r.is_a?(Array)
      
      merged_relation = clone
      merged_query = merged_relation.sunspot_search.query
      incoming_query = r.sunspot_search.query
      
      
    end
  end
end