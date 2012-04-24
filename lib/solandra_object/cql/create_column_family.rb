module SolandraObject#:nodoc:
  module Cql #:nodoc:
    class CreateColumnFamily #:nodoc:
      def initialize(cf_name)
        @cf_name = cf_name
        @columns = {}
        @storage_parameters = {}
      end
      
      def with(with)
        @storage_parameters.merge!(with)
        self
      end
      
      def columns(columns)
        @columns.merge! = columns
        self
      end
      
      def limit(limit)
        @limit = limit
        self
      end
      
      def to_cql
        stmt = "CREATE COLUMNFAMILY #{cf_name} (key uuid PRIMARY KEY"
        @columns.each do |name,type|
          stmt << ", #{name} #{type}"
        end
        stmt << ")"
        unless @storage_parameters.empty?
          stmt << " WITH "
          first_parm = @storage_parameter.shift
          stmt << "#{first_parm.first} = '#{first_parm.last}'"
          
          @storage_parameters.each do |key, value|
            stmt << " AND #{key} = '#{value}'"
          end
        end
        
        stmt
      end
    end
  end
end