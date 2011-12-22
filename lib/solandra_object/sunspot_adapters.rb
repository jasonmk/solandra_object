module SolandraObject
  #
  # This module provides Sunspot Adapter implementations for Solandra Object models
  #
  module SunspotAdapters
    class SolandraObjectInstanceAdapter < Sunspot::Adapters::InstanceAdapter
      #
      # Return the primary key for the adapted instance
      #
      # ==== Returns
      # 
      # String:: UUID of the model
      #
      def id
        @instance.id
      end
    end
    
    class SolandraObjectDataAccessor < Sunspot::Adapters::DataAccessor
      # options for the find
      attr_accessor :include, :select
      
      #
      # Set the fields to select from the database. This will be passed
      # to SolandraObject
      #
      def select=(value)
        value = value.join(', ') if value.respond_to?(:join)
        @select = value
      end
      
      #
      # Get one SolandraObject instance out of the database by ID
      #
      # ==== PArameters
      #
      # id<String>:: UUID of the the model to retrieve
      #
      # ==== Returns
      #
      # SolandraObject::Base:: SolandraObject model
      #
      def load(id)
        @clazz.multi_find([id])
      end
      
      # 
      # Get a collection of SolandraObject instances out of the database by ID
      #
      # ==== Parameters
      #
      # ids<Array>:: UUIDs of the models to retrieve
      #
      # ==== Returns
      #
      # Array:: Collection of SolandraObject models
      #
      def load_all(ids)
        @clazz.multi_find(ids)
      end

      private

      def options_for_find
        options = {}
        options[:include] = @include unless @include.blank?
        options[:select]  =  @select unless  @select.blank?
        options
      end
    end
  end
end