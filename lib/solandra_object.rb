require 'active_support/all'

module SolandraObject
  extend ActiveSupport::Autoload
  
  autoload :Base
  autoload :AttributeMethods
  autoload :CassandraFinderMethods
  autoload :SunspotAdapters
  autoload :Validations
  autoload :Associations
  autoload :Reflection
  autoload :Relation
  
  autoload_under 'relation' do
    autoload :FinderMethods
    autoload :ModificationMethods
    autoload :SearchMethods
    autoload :SpawnMethods
  end
  
  autoload :NamedScope
  autoload :Persistence
end

require 'solandra_object/railtie' if defined?(Rails)
require 'solandra_object/errors'
require 'solandra_object/sunspot_types'

if Rails.env.test?
  # In order to run the unit tests properly, we need to clear out the
  # database and index between each test.  This file helps facilitate
  # that functionality.
  require 'solandra_test_hook'
end

ActiveSupport.run_load_hooks(:solandra_object, SolandraObject::Base)