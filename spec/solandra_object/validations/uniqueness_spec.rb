require 'spec_helper'

class TestUnqiueness
  include ActiveModel::Validations
  include SolandraObject::Validations
  
  validates :name, :uniqueness => true
end

describe SolandraObject::Validations::UniquenessValidator do
 
end
