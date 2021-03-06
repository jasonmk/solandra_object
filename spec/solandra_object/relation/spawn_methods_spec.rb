require 'spec_helper'

describe SolandraObject::Relation do
  before(:each) do
    @relation = SolandraObject::Relation.new(Hobby, "hobbies")
  end
  
  describe "#merge" do
    it "should merge two relations" do
      r1 = @relation.where("name" => "biking")
      r2 = @relation.order("name" => :desc)
      r1.merge(r2).should == @relation.where("name" => "biking").order("name" => :desc)
    end
    
    it "should merge where conditions into a single hash" do
      r1 = @relation.where("name" => "biking")
      r2 = @relation.where("complexity" => 1.0)
      r1.merge(r2).where_values.should == [{"name" => "biking", "complexity" => 1.0}]
    end
    
    it "should overwrite conditions on the same attribute" do
      r1 = @relation.where("name" => "biking")
      r2 = @relation.where("name" => "swimming")
      r1.merge(r2).where_values.should == [{"name" => "swimming"}]
      r2.merge(r1).where_values.should == [{"name" => "biking"}]
    end
  end
end
