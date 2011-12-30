class Person < SolandraObject::Base
  self.column_family = "people"
  
  has_one :job
  has_many :cars
  has_and_belongs_to_many :hobbies
  
  key :uuid
  string :name
  date :birthdate
  
  validates :name, :presence => true, :uniqueness => :true
end

class Car < SolandraObject::Base
  self.column_family = "cars"
  
  belongs_to :person
  
  key :uuid
  string :name
  string :person_id
end

class Job < SolandraObject::Base
  self.column_family = "jobs"
  
  belongs_to :person
  
  key :uuid
  string :title
  string :person_id
end

class Boat < SolandraObject::Base
  self.column_family = "boats"
  
  key :uuid
  string :name
end

class Hobby < SolandraObject::Base
  self.column_family = "hobbies"
  
  has_and_belongs_to_many :people
  
  key :uuid
  string :name
  float :complexity
end