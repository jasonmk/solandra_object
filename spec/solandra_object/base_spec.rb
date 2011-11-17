require 'spec_helper'

describe SolandraObject::Base do
  it "should inherit from CassandraObject::Base" do
    SolandraObject::Base.ancestors.should include(CassandraObject::Base)
  end
end
