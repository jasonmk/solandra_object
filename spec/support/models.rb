class Person < SolandraObject::Base
  self.column_family = "people"
  
  key :uuid
  string :name
  date :birthdate
  
  validates :name, :presence => true, :uniqueness => :true
end

class Car < SolandraObject::Base
  self.column_family = "cars"
  
  key :uuid
  string :name
end

class Job < SolandraObject::Base
  self.column_family = "jobs"
  
  key :uuid
  string :title
end

class Boat < SolandraObject::Base
  self.column_family = "boats"
  
  key :uuid
  string :name
end

class Hobby < SolandraObject::Base
  self.column_family = "hobbies"
  
  key :uuid
  string :name
end