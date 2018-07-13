class ScoreStudentStat < ActiveRecord::Base
	belongs_to :program
	enum tipo: [:evaluation, :refilable, :questions ]
end
