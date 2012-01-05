module SolandraObject
  module SpawnMethods
    def scoped #:nodoc:
      self
    end
    
    def merge(r) #:nodoc:
      return self unless r
      return to_a & r if r.is_a?(Array)
      
      merged_relation = clone
      
      (Relation::MULTI_VALUE_METHODS - [:where, :where_not]).each do |method|
        value = r.send(:"#{method}_values")
        merged_relation.send(:"#{method}_values=", merged_relation.send(:"#{method}_values") + value) if value.present?
      end
      
      merged_wheres = {}
      # This will merge all the where clauses into a single hash.  If the same attribute is
      # specified multiple times, the last one will win.
      (@where_values + r.where_values).each { |w| merged_wheres.merge!(w)}
      
      merged_relation.where_values = [merged_wheres] unless merged_wheres.empty?
      
      merged_where_nots = {}
      # This will merge all the where not clauses into a single hash.  If the same attribute is
      # specified multiple times, the last one will win.
      (@where_not_values + r.where_not_values).each { |w| merged_where_nots.merge!(w)}
      
      merged_relation.where_not_values = [merged_where_nots] unless merged_where_nots.empty?
      
      (Relation::SINGLE_VALUE_METHODS).each do |method|
        value = r.send(:"#{method}_value")
        merged_relation.send(:"#{method}_value=", value) unless value.nil?
      end
      
      merged_relation
    end
    
    VALID_FIND_OPTIONS = [:conditions, :limit, :offset, :order, :group, :page, :per_page]
    def apply_finder_options(options) #:nodoc:
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