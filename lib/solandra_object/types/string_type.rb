module SolandraObject
  module Types
    class StringType < BaseType
      def encode(str)
        raise ArgumentError.new("#{self} requires a String") unless str.kind_of?(String)
        str.dup
      end

      def wrap(record, name, value)
        txt = (value.frozen? ? value.dup : value)
        txt.respond_to?(:force_encoding) ? txt.force_encoding('UTF-8') : txt
      end
    end
  end
end