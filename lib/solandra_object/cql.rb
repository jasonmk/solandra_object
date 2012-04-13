module SolandraObject
  class Cql
    class << self
      def perform_update(model)
        return true unless model.changed?
        model.updated_at = Time.now
        updated_attributes = model.changes.keys
        "UPDATE #{model.column_family} SET "
      end
      
      def sanitize(str)
        
      end
    end
  end
end