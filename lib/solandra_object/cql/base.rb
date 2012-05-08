module SolandraObject
  module Cql
    class Base
      def to_cql #:nodoc:
        nil
      end
      
      def execute
        cql = self.to_cql
        Rails.logger.debug(cql)
        SolandraObject::Base.connection.execute_cql_query(cql)
      end
    end
  end
end