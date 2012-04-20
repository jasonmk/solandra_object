module SolandraObject
  module Cql
    extend ActiveSupport::Autoload
    class << self
      def for_class(klass)
        @cql[klass] ||= SolandraObject::Cql::ColumnFamily.new(klass)
      end
    end
    
    autoload :ColumnFamily
    autoload :Consistency
    autoload :Insert
    autoload :Select
  end
end