module SolandraObject#:nodoc:
  module Cql #:nodoc:
    class CreateKeyspace #:nodoc:
      def initialize(ks_name)
        @ks_name = ks_name
        @strategy_class
        @strategy_options = {}
      end
      
      def strategy_class(sc)
        @strategy_class = sc
        self
      end
      
      def strategy_option(so)
        @strategy_options.merge!(so)
        self
      end
      
      def to_cql
        stmt = "CREATE KEYSPACE #{@ks_name} WITH strategy_class = '#{@strategy_class}'"
        
        @strategy_options.each do |key, value|
          stmt << " AND #{key.to_s} = '#{value.to_s}'"
        end
        
        stmt
      end
    end
  end
end