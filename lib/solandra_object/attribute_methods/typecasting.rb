module SolandraObject
  module AttributeMethods
    module Typecasting
      extend ActiveSupport::Concern

      included do
        class_attribute :attribute_definitions
        class_attribute :lazy_attributes
        self.attribute_definitions = {}
        self.lazy_attributes = []

        %w(array boolean date float integer json string text time time_with_zone).each do |type|
          instance_eval <<-EOV, __FILE__, __LINE__ + 1
            def #{type}(name, options = {})                               # def string(name, options = {})
              attribute(name, options.update(:type => :#{type}))             #   attribute(name, options.update(type: :string))
            end                                                           # end
          EOV
        end
        
        def binary(name, options = {})
          options.reverse_merge!(:lazy => true)
          attribute(name, options.update(:type => :binary))
        end
      end

      module ClassMethods
        def inherited(child)
          super
          child.attribute_definitions = attribute_definitions.dup
        end

        def typecast_attribute(record, name, value)
          if attribute_definition = attribute_definitions[name.to_sym]
            attribute_definition.instantiate(record, value)
          else
            raise NoMethodError, "Unknown attribute #{name.inspect}"
          end
        end
      end
    end
  end
end