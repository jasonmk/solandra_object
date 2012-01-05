require 'active_support/all'
require 'sunspot_extensions'

module SolandraObject
  extend ActiveSupport::Autoload
  
  autoload :Base
  autoload :Connection
  autoload :AttributeMethods
  autoload :Consistency
  autoload :Persistence
  autoload :Callbacks
  autoload :Validations
  autoload :Identity
  autoload :Serialization
  autoload :Migrations
  autoload :Cursor
  autoload :Collection
  autoload :Mocking
  autoload :Batches
  autoload :FinderMethods
  autoload :Timestamps
  autoload :Type
  autoload :Schema
  
  module AttributeMethods
    extend ActiveSupport::Autoload
    
    eager_autoload do
      autoload :Definition
      autoload :Dirty
      autoload :Typecasting
    end
  end
  
  autoload :SunspotAdapters
  autoload :Associations
  autoload :Reflection
  autoload :Relation
  
  autoload_under 'relation' do
    autoload :SearchMethods
    autoload :SpawnMethods
  end
  
  autoload :NamedScope
  
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

require 'solandra_object/railtie' if defined?(Rails)
require 'solandra_object/errors'
require 'solandra_object/sunspot_types'
require 'thrift_fix'

if Rails.env.test?
  # In order to run the unit tests properly, we need to clear out the
  # database and index between each test.  This file helps facilitate
  # that functionality.
  require 'solandra_test_hook'
end

ActiveSupport.run_load_hooks(:solandra_object, SolandraObject::Base)