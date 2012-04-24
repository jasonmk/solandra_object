module SolandraObject#:nodoc:
  module Cql #:nodoc:
    class Select #:nodoc:
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
        stmt = "SELECT #{@select} FROM #{@klass.column_family} USING CONSISTENCY #{@consistency} #{@conditions.empty? ? '' : 'WHERE '}"
        @conditions.each do |k,v|
          values << v
          if v.kind_of?(Array)
            stmt << "#{k.to_s} IN (?) "
          else
            stmt << "#{k.to_s} = ? "
          end
        end
        if @limit
          stmt << "LIMIT #{@limit}"
        end
        CassandraCQL::Statement.sanitize(stmt, values)
      end
    end
  end
end