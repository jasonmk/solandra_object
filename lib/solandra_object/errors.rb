module SolandraObject
  class SolandraObjectError < StandardError
  end
  
  class AssociationTypeMismatch < SolandraObjectError
  end
  
  class RecordNotSaved < SolandraObjectError
  end
  
  class DeleteRestrictionError < SolandraObjectError
  end
end