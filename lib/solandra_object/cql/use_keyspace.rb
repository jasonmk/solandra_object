module SolandraObject
  module Cql
    class UseKeyspace
      def initialize(ks_name)
        @ks_name = ks_name
      end
      
      def to_cql
        "USE #{@ks_name}"
      end
    end
  end
end