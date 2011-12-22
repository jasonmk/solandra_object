module SolandraObject
  module FinderMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def multi_find(keys)
        keys = Array(keys)
        key_strings = keys.collect {|k| k.try :to_s}.compact

        return [] if key_strings.empty?
        
        results = connection.multi_get(column_family, key_strings, {:count => 5000}).presence
        
        return [] if results.nil?
        
        models = []
        key_strings.each do |key|
          attributes = results[key].presence
          if attributes.blank?
            # It wasn't found in Cassandra.  Let's remove it from Sunspot so that we don't keep finding it.
            Sunspot.remove_by_id(self.name, key) rescue nil
          else
            models << instantiate(key, attributes)
          end
        end
        models
      end
    end
  end
end