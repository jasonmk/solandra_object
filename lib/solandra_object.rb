require 'active_support/all'
module SolandraObject
  extend ActiveSupport::Autoload
  
  autoload :Base
  autoload :AttributeMethods
  autoload :SunspotAdapters
end

require 'solandra_object/railtie' if defined?(Rails)
require 'solandra_object/sunspot_types'
