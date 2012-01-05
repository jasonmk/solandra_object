require 'solandra_object'
require 'sunspot_rails'
require 'rails'
module SolandraObject
  class Railtie < Rails::Railtie
    initializer 'solandra_object.init', :after => 'sunspot_rails.init' do
      ActiveSupport.on_load(:solandra_object) do
        Sunspot::Adapters::InstanceAdapter.register(SolandraObject::SunspotAdapters::SolandraObjectInstanceAdapter, SolandraObject::Base)
        Sunspot::Adapters::DataAccessor.register(SolandraObject::SunspotAdapters::SolandraObjectDataAccessor, SolandraObject::Base)
        include(Sunspot::Rails::Searchable)
      end
    end
    
    rake_tasks do
      load 'tasks/solandra_object_tasks.rake'
      load 'solandra_object/tasks/ks.rake'
    end
    
    generators do
      require 'solandra_object/generators/migration_generator'
    end
  end
end