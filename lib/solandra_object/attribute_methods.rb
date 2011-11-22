module SolandraObject
  module AttributeMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def attribute(name, options)
        type = options[:type]
        options[:type] = :string if options[:type].to_s == "text"
        
        searchable = options.delete :searchable
        searchable = true if searchable.nil?
        
        super
        
        if(searchable)
          searchable do
            send type, name.to_s
          end
        end
        
        # Check for unique ID field in SOLR config. Add it if it's not there.
        # Note that this probably doesn't belong here but I couldn't
        # find a better place for it just yet. -JMK
        unless Sunspot::Setup.for(self).fields.detect {|f|f.name == :unique_id}
          searchable do
            string "unique_id", :using => :id
          end
        end
      end
    end
  end
end