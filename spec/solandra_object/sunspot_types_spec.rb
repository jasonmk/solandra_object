require 'spec_helper'
require 'solandra_object/sunspot_types'

describe Sunspot::Type do
  describe Sunspot::Type::JsonType do
    it "inherits behavior from Sunspot's TextType" do
      Sunspot::Type::JsonType.ancestors.should include(Sunspot::Type::TextType)
    end
  end
end
