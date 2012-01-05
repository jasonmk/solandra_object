module SolandraObject
  module AttributeMethods
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    
    included do
      alias :[] :read_attribute
      alias :[]= :write_attribute

      attribute_method_suffix("", "=")
    end
    
    module ClassMethods
      def define_attribute_methods
        return if attribute_methods_generated?
        super(attribute_definitions.keys)
        @attribute_methods_generated = true
      end

      def attribute_methods_generated?
        @attribute_methods_generated ||= false
      end
      
      def attribute(name, options)
        type = options[:type]
        options[:type] = :string if options[:type].to_s == "text"
        
        searchable = options.delete :searchable
        searchable = true if searchable.nil?
        
        super
        
        if(searchable)
          searchable do
            options.delete :unique
            if(type.to_s == 'array')
              options[:multiple] = true
              type = options.delete(:array_type) || "string"
            end
            send type, name.to_s, options
          end
        end
        
        # Check for unique ID field in SOLR config. Add it if it's not there.
        # Note that this probably doesn't belong here but I couldn't
        # find a better place for it just yet. While we're add it, we'll index
        # the created and modified dates. -JMK
        unless Sunspot::Setup.for(self).fields.detect {|f|f.name == :unique_id}
          searchable do
            string "unique_id", :using => :id
            # time "updated_at"
            # time "created_at"
          end
        end
      end
    end
    
    def write_attribute(name, value)
      @attributes[name.to_s] = self.class.typecast_attribute(self, name, value)
    end

    def read_attribute(name)
      @attributes[name.to_s]
    end

    def attribute_exists?(name)
      @attributes.key?(name.to_s)
    end

    def attributes=(attributes)
      attributes.each do |(name, value)|
        send("#{name}=", value)
      end
    end

    def method_missing(method_id, *args, &block)
      if !self.class.attribute_methods_generated?
        self.class.define_attribute_methods
        send(method_id, *args, &block)
      else
        super
      end
    end

    def respond_to?(*args)
      self.class.define_attribute_methods unless self.class.attribute_methods_generated?
      super
    end

    protected
      def attribute_method?(name)
        !!attribute_definitions[name.to_sym]
      end

    private
      def attribute(name)
        read_attribute(name)
      end

      def attribute=(name, value)
        write_attribute(name, value)
      end
  end
end