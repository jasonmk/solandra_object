require 'active_support/all'
module SolandraObject
  extend ActiveSupport::Autoload
  
  autoload :Base
  autoload :AttributeMethods
  autoload :SunspotAdapters
  autoload :Validations
  autoload :Associations
  autoload :Reflection
  autoload :Relation
  
  autoload_under 'relation' do
    autoload :SearchMethods
  end
end

require 'solandra_object/railtie' if defined?(Rails)
require 'solandra_object/errors'
require 'solandra_object/sunspot_types'

ActiveSupport.run_load_hooks(:solandra_object, SolandraObject::Base)