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
  end
end