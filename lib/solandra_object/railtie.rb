require 'solandra_object'
require 'rails'
module SolandraObject
  class Railtie < Rails::Railtie
    initializer 'solandra_object.init', :after => 'sunspot_rails.init' do
      ActiveSupport.on_load(:solandra_object) do
      end
      config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))
      SolandraObject::Base.establish_connection(config[Rails.env].symbolize_keys)
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