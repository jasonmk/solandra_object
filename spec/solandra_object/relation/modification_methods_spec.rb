require 'spec_helper'

describe SolandraObject::Relation do
  before(:each) do
    @relation = SolandraObject::Relation.new(Hobby, "hobbies")
  end
  
  describe "Modification Methods" do
    describe "#destroy_all" do
      it "should destroy all matching records" do
        Hobby.create(:name => "biking", :complexity => 1.0)
        Hobby.create(:name => "skydiving", :complexity => 4.0)
        Sunspot.commit
        debugger
        @relation.where(:complexity).greater_than(2.0).destroy_all
        Sunspot.commit
        @relation.count.should == 1
      end
    end
    
    describe "#destroy" do
      before(:each) do
        @h1 = Hobby.create(:name => "biking", :complexity => 1.0)
        @h2 = Hobby.create(:name => "skydiving", :complexity => 4.0)
        Sunspot.commit 
      end
      
      it "should destroy 1 record by id" do
        @relation.destroy(@h1.id)
        Sunspot.commit
        @relation.count.should == 1
      end
      
      it "should destroy multiple records by id" do
        @relation.destroy([@h1.id, @h2.id])
        Sunspot.commit
        @relation.count.should == 0
      end
    end
  end
end
