require 'spec_helper'

describe SolandraObject::Relation do
  before(:each) do
    @relation = SolandraObject::Relation.new(Hobby, "hobbies")
  end
  
  describe "#first" do
    it "should return the first result if records are already loaded" do
      a_record = mock_model(Hobby)
      @relation.stub(:loaded? => true)
      @relation.instance_variable_set(:@results, [a_record, mock_model(Hobby)])
      @relation.first.should == a_record
    end
    
    it "should look up the first result if records are not already loaded" do
      a_record = mock_model(Hobby)
      @relation.stub(:loaded? => false)
      mock_relation = mock(SolandraObject::Relation, :to_a => [a_record])
      @relation.should_receive(:limit).with(1).and_return(mock_relation)
      @relation.first.should == a_record
    end
  end
  
  describe "#first!" do
    it "should raise RecordNotFound if no record is returned" do
      lambda { @relation.first! }.should raise_exception(SolandraObject::RecordNotFound)
    end
  end
  
  describe "#last" do
    it "should return the last result if records are already loaded" do
      a_record = mock_model(Hobby)
      @relation.stub(:loaded? => true)
      @relation.instance_variable_set(:@results, [mock_model(Hobby), a_record])
      @relation.last.should == a_record
    end
    
    it "should look up the last result if records are not already loaded" do
      a_record = mock_model(Hobby)
      @relation.stub(:loaded? => false)
      mock_relation = mock(SolandraObject::Relation, :to_a => [a_record])
      @relation.should_receive(:reverse_order).and_return(mock_relation)
      mock_relation.should_receive(:limit).with(1).and_return(mock_relation)
      @relation.last.should == a_record
    end
  end
  
  describe "#last!" do
    it "should raise RecordNotFound if no record is returned" do
      lambda { @relation.last! }.should raise_exception(SolandraObject::RecordNotFound)
    end
  end
end