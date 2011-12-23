require 'spec_helper'

describe SolandraObject::Base do
  describe "uniqueness validation" do
    it "should validate uniqueness" do
      Person.create(:name => "Jason")
      Sunspot.commit
      person = Person.new(:name => "Jason")
      person.should_not be_valid
      person.name = "John"
      person.should be_valid
    end
  end
end
