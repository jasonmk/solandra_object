module SolandraObject
  module Types
    class BinaryType < BaseType
      DEFAULTS = {:solr_type => false, :indexed => false, :stored => false, :multi_valued => false, :sortable => false, :tokenized => false, :fulltext => false}
      def encode(str)
        raise ArgumentError.new("#{self} requires a String") unless str.kind_of?(String)
        str.dup
      end

      def wrap(record, name, value)
        (value.frozen? ? value.dup : value)
      end
    end
  end
end