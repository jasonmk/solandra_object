module SolandraObject
  module Cql
    class ColumnFamily
      def initialize(klass)
        @klass = klass
      end
      
      def select(*columns)
        columns << "*" if columns.empty?
        SolandraObject::Cql::Statement.new(klass, columns)
      end
    end
  end
end