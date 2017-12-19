class LearningPath < ActiveRecord::Base
	has_many :groups
	has_many :group2s, class_name: "Group", foreign_key: "learning_path2_id"
	has_many :learning_path_contents, :dependent => :delete_all
	enum tipo: [ :fisica, :moral ]

	def self.LP_type_options
    	[['Fisica', 'fisica'], ['Moral', 'moral']]
  	end
	def count_programs
		return self.learning_path_contents.count
	end
	def count_groups
		if self.tipo == "fisica"
			return self.groups.count
		elsif self.tipo == "moral"
			return self.group2s.count
		else
			return 0	
		end		
	end	
end
