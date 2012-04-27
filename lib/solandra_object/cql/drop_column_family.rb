module SolandraObject
  module Cql
    class DropColumnFamily
      def initialize(cf_name)
        @cf_name = cf_name
      end
      
      def to_cql
        "DROP COLUMNFAMILY #{@cf_name}"
      end
    end
  end
end