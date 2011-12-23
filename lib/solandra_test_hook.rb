require 'active_support'
require 'solandra_object'
require 'solandra_object/base'
module SolandraObject
  class Base
    class_attribute :recorded_classes
    
    def save_with_record_class(*args)
      SolandraObject::Base.recorded_classes[self.class] = nil
      save_without_record_class(*args)
    end
    alias_method_chain :save, :record_class
  end
end