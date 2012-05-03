module SolandraObject
  module Cql
    class Base
      def to_cql #:nodoc:
        nil
      end
      
      def execute
        SolandraObject::Base.connection.execute_cql_query(self.to_cql)
      end
    end
  end
end