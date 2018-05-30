class Mentor < User
  default_scope { mentors }

  def linked_students
  	linked = 0
  	self.groups.each do |group|
  		linked += group.students.count
  	end
  	linked	
  end	
end
