module SolandraObject
  module AttributeMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def attribute(name, options)
        type = options[:type]
        searchable = options.delete :searchable
        searchable = true if searchable.nil?
        super
        if(searchable)
          searchable do
            send type, name.to_s
          end
        end
      end
    end
  end
end