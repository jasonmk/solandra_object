module SolandraObject
  module FinderMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def find(keys)
        key_string = key.try :to_s

        if key_string.blank?
          raise SolandraObject::RecordNotFound, "Couldn't find #{self.name} with key #{key.inspect}"
        elsif attributes = connection.get(column_family, key_string, {:count => 500}).presence
          instantiate(key_string, attributes)
        else
          raise SolandraObject::RecordNotFound
        end
      end
      
      def find_by_id(key)
        find(key)
      rescue CassandraObject::RecordNotFound
        nil
      end
      
      def multi_find(*keys)
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