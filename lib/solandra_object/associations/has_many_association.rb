module SolandraObject
  module Associations
    class HasManyAssociation < CollectionAssociation #:nodoc:
      private
      
        def count_records
          scoped.count
        end
        
        
    end
  end
end