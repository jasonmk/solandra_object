module SolandraObject
  class Collection < Array
    attr_accessor :last_column_name
    def inspect
      "<SolandraObject::Collection##{object_id} contents: #{super} last_column_name: #{last_column_name.inspect}>"
    end
  end
end