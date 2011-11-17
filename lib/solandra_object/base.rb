require 'jkusar-cassandra_object'
module SolandraObject
  class Base < ::CassandraObject::Base
    include AttributeMethods
  end
end