module SolandraObject
  module AttributeMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def attribute(name, options)
        type = options[:type]
        super
        searchable do
          send type, name.to_s  
        end
      end
    end
  end
end