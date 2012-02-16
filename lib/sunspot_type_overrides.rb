require 'sunspot'
#require 'sunspot/type.rb'

module Sunspot #:nodoc:
  module Type #:nodoc:
    class <<self #:nodoc:
      def to_indexed(object) #:nodoc:
        if type = self.for(object)
          type.to_indexed(object)
        else
          object.to_s unless object.blank?
        end
      end
    end
    
    class TextType #:nodoc:
      def to_indexed(value) #:nodoc:
        value.to_s unless value.blank?
      end
    end
    
    class StringType #:nodoc:
      def to_indexed(value) #:nodoc:
        value.blank? ? nil : value.to_s
      end
    end
  end
end