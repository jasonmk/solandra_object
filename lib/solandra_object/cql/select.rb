module SolandraObject
  module Cql
    class Select
      def initialize(klass, select)
        @klass = klass
        @select = select.join(",")
        @consistency = SolandraObject::Cql::Consistency::LOCAL_QUORUM
        @limit = nil
        @conditions = {}
      end
      
      def using(consistency)
        @consistency = consistency
        self
      end
      
      def conditions(conditions)
        @conditions.merge!(conditions)
        self
      end
      
      def limit(limit)
        @limit = limit
        self
      end
      
      def to_cql
        values = []
        stmt = "select #{@select} from #{@klass.column_family} using consistency #{@consistency} #{@conditions.empty? ? '' : 'where '}"
        @conditions.each do |k,v|
          values << v
          if v.kind_of?(Array)
            stmt << "#{k} IN (?) "
          else
            stmt << "#{k} = ? "
          end
        end
        if @limit
          stmt << "limit #{@limit}"
        end
        CassandraCQL::Statement.sanitize(stmt, values)
      end
    end
  end
end