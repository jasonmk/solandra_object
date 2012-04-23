module SolandraObject
  module Cql
    class ColumnFamily
      def initialize(klass)
        @klass = klass
      end
      
      def delete(*keys)
        SolandraObject::Cql::Delete.new(klass, keys.flatten)
      end
      
      def insert
        SolandraObject::Cql::Insert.new(klass)
      end
      
      def select(*columns)
        columns << "*" if columns.empty?
        SolandraObject::Cql::Select.new(klass, columns.flatten)
      end

      def truncate
        SolandraObject::Cql::Truncate.new(klass)
      end
      
      def update(*keys)
        SolandraObject::Cql::Update.new(klass, keys.flatten)
      end
    end
  end
end