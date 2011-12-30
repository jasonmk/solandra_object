require 'spec_helper'

describe SolandraObject::Base do
  describe "Relations" do
    describe "belongs_to" do
      it "should set the id when setting the object" do
        person = Person.create(:name => "Jason")
        job = Job.create(:title => "Developer")
        job.person = person
        job.person_id.should == person.id
      end
      
      it "should look up the owning model by id" do
        person = Person.new(:name => "John")
        puts person.save
        puts person.errors.inspect
        puts person.name + " - " + person.id
        puts "======"
        job = Job.new(:title => "Developer", :person_id => person.id)
        puts job.save
        puts job.title + " - " + job.id
        Sunspot.commit
        Job.first.person.should == person
      end
    end
  end
end
