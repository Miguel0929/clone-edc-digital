class StudentEvaluatedPointsStateMentor < ActiveRecord::Base
	belongs_to :program
	belongs_to :state
	belongs_to :mentor
	enum tipo: [:evaluation, :refilable, :questions ]
end
