class StudentEvaluatedPointsState < ActiveRecord::Base
	belongs_to :program
	belongs_to :state
	enum role: [:evaluation, :refilable, :questions ]

end
