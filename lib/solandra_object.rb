require 'active_support/all'
require 'sunspot_type_overrides'
require 'cassandra/0.8'

module SolandraObject
  extend ActiveSupport::Autoload
  
  autoload :Associations
  autoload :AttributeMethods
  autoload :Base
  autoload :Batches
  autoload :Callbacks
  autoload :CassandraFinderMethods
  autoload :Collection
  autoload :Connection
  autoload :Consistency
  autoload :Cursor
  autoload :Identity
  autoload :Migrations
  autoload :Mocking
  autoload :Persistence
  autoload :Reflection
  autoload :Relation
  
  autoload_under 'relation' do
    autoload :FinderMethods
    autoload :ModificationMethods
    autoload :SearchMethods
    autoload :SpawnMethods
    autoload :Cql
  end
  
  autoload :Schema
  autoload :Scoping
  autoload :Serialization
  autoload :SunspotAdapters
  autoload :Timestamps
  autoload :Type
  autoload :Validations
  
  module AttributeMethods
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Definition
      autoload :Dirty
      autoload :Typecasting
    end
  end

  module Tasks
    extend ActiveSupport::Autoload
    autoload :Keyspace
    autoload :ColumnFamily
  end

  module Types
    extend ActiveSupport::Autoload
    
    autoload :BaseType
    autoload :ArrayType
    autoload :BooleanType
    autoload :DateType
    autoload :FloatType
    autoload :IntegerType
    autoload :JsonType
    autoload :StringType
    autoload :TimeType
    autoload :TimeWithZoneType
  end
end

# Fixup the thrift library
require "thrift"
module Thrift
  class BinaryProtocol
    def write_string(str)
      write_i32(str.bytesize)
      trans.write(str)
    end
  end
end

require 'solandra_object/railtie' if defined?(Rails)
require 'solandra_object/errors'
require 'solandra_object/sunspot_types'
require 'solr_no_escape'

if Rails.env.test?
  # In order to run the unit tests properly, we need to clear out the
  # database and index between each test.  This file helps facilitate
  # that functionality.
  require 'solandra_test_hook'
end

ActiveSupport.run_load_hooks(:solandra_object, SolandraObject::Base)