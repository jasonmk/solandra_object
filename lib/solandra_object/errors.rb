module SolandraObject
  class SolandraObjectError < StandardError
  end
  
  class AssociationTypeMismatch < SolandraObjectError
  end
  
  class RecordNotSaved < SolandraObjectError
  end
  
  class DeleteRestrictionError < SolandraObjectError
  end
  
  class RecordNotFound < SolandraObjectError
  end
  
  class RecordInvalid < SolandraObjectError
    attr_reader :record
    def initialize(record)
      @record = record
      super("Invalid record: #{@record.errors.full_messages.to_sentence}")
    end
  end
end