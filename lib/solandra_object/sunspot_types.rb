module Sunspot #:nodoc:
  module Type #:nodoc:
    #
    # JSON is how Cassandra stores hashes.  For the purpose of
    # searching, we are just storing the JSON as text and letting
    # Solandra tokenize it like normal.  If this isn't what you
    # want then you probably need to define a virtual attribute
    # yourself.
    #
    class JsonType < Sunspot::Type::TextType #:nodoc:

    end
    Sunspot::Type.register JsonType, JSON
    
  end
end