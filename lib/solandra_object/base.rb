require 'jkusar-cassandra_object'
module SolandraObject
  class Base < ::CassandraObject::Base
    include AttributeMethods
    include Validations
    include Reflection
    include Associations
  end
end