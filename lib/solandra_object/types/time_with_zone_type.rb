module SolandraObject
  module Types
    class TimeWithZoneType < BaseType
      def encode(time)
        raise ArgumentError.new("#{self} requires a Time") unless time.kind_of?(Time)
        time.utc.xmlschema(6)
      end

      def decode(str)
        return nil if str.empty?
        return nil unless str.kind_of?(String) && str.match(TimeType::REGEX)
        Time.xmlschema(str).in_time_zone
      end
    end
  end
end