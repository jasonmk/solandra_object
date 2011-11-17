require 'solandra_object'
require 'sunspot'
require 'sunspot/rails'
require 'rails'
module SolandraObject
  class Railtie < Rails::Railtie
    initializer 'solandra_object.init', :after => 'sunspot_rails.init' do
      SolandraObject::Base.instance_eval do
        Sunspot::Adapters::InstanceAdapter.register(SolandraObject::SunspotAdapters::SolandraObjectInstanceAdapter)
        Sunspot::Adapters::DataAccessor.register(SolandraObject::SunspotAdapters::SolandraObjectDataAccessor)
        include(Sunspot::Rails::Searchable)
      end
    end
  end
end