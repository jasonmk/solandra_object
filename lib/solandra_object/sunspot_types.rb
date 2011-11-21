module Sunspot
  module Type
    #
    # Array is a special type that allows multiple values to be
    # stored in an array.  For the purpose of searching, they
    # are converted to a single joined text field.  This allows
    # the values to be tokenized by Solandra.  The values of the
    # array will have to_s called on them.  Hopefully, this
    # returns something useful.
    #
    class ArrayType < Sunspot::Type::TextType
      # def indexed_name(name) #:nodoc:
        # "#{name}_text"
      # end
#       
      # def to_indexed(value) #:nodoc:
        # value.collect {|v| v.to_s}.join("\t")
      # end
#       
      # def cast(string) #:nodoc:
        # string.split(/\t/)
      # end
    end
    Sunspot::Type.register ArrayType, Array
    
    #
    # JSON is how Cassandra stores hashes.  For the purpose of
    # searching, we are just storing the JSON as text and letting
    # Solandra tokenize it like normal.  If this isn't what you
    # want then you probably need to define a virtual attribute
    # yourself.
    #
    class JsonType < Sunspot::Type::TextType

    end
    Sunspot::Type.register JsonType, JSON
    
  end
end