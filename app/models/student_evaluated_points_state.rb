class StudentEvaluatedPointsState < ActiveRecord::Base
	belongs_to :program
	belongs_to :state
	enum tipo: [:evaluation, :refilable, :questions ]
end
