class StudentEvaluatedState < ActiveRecord::Base
	belongs_to :program
	belongs_to :state
end
