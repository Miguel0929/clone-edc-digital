class LearningPath < ActiveRecord::Base
	has_many :groups
	has_many :learning_path_programs, :dependent => :delete_all
	has_many :learning_path_contents, :dependent => :delete_all
	def count_programs
		return self.learning_path_contents.count
	end
	def count_groups
		return self.groups.count
	end	
end
