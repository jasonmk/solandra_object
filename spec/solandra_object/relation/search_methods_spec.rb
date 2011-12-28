require 'spec_helper'

describe SolandraObject::Relation do
  before(:each) do
    @relation = SolandraObject::Relation.new(Hobby, "hobbies")
  end
  
  describe "#limit" do
    it "should limit the page size" do
      "a".upto("l") do |letter|
        Hobby.create(:name => letter)
      end
      Sunspot.commit
      @relation.limit(7).all.size.should == 7
    end
  end
  
  describe "#offset" do
    it "should skip into the result set by the given amount" do
      "a".upto("l") do |letter|
        Hobby.create(:name => letter)
      end
      Sunspot.commit
      @relation.offset(4).order(:name).first.name.should == "e"
    end
  end
  
  describe "#page" do
    it "should get a particular page" do
      "a".upto("l") do |letter|
        Hobby.create(:name => letter)
      end
      Sunspot.commit
      @relation.per_page(3).page(2).order(:name).all.first.name.should == "d"
    end
  end
  
  describe "#group" do
    
  end
  
  describe "#order" do
    
  end
  
  describe "#search" do
    it "should allow searches using the sunspot search object" do
      %w[fishing hiking boating jogging swimming chess].each do |word|
        Hobby.create(:name => word)
      end
      Sunspot.commit
      @relation.search do
        fulltext 'fishing OR swimming'
        order_by :name
        adjust_solr_params do |params|
          params.delete :defType
        end
      end.count.should == 2
    end
  end
  
  describe "#where" do
    
  end
  
  describe "#fulltext" do
    
  end
end