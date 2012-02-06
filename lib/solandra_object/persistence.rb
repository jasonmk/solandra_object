module SolandraObject
  module Persistence
    extend ActiveSupport::Concern
    
    private
      # Override the write method to force a Sunspot commit
      def write #:nodoc:
        super
        Sunspot.commit
      end
  end
end