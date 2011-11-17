require 'spec_helper'
require 'solandra_object/sunspot_types'

describe Sunspot::Type do
  describe Sunspot::Type::ArrayType do
    it "assigns an indexed name for solr to recognize" do
      Sunspot::Type::ArrayType.instance.indexed_name("my_field").should == "my_field_text"
    end
    
    it "should convert an array to a tab separated list" do
      Sunspot::Type::ArrayType.instance.to_indexed(['a','b','c']).should == "a\tb\tc"
    end
    
    it "should convert a string back into an array" do
      Sunspot::Type::ArrayType.instance.cast("a\tb\tc").should == ['a','b','c']
    end
  end
  
  describe Sunspot::Type::JsonType do
    it "inherits behavior from Sunspot's TextType" do
      Sunspot::Type::JsonType.ancestors.should include(Sunspot::Type::TextType)
    end
  end
end
