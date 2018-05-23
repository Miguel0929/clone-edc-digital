class UserEvaluationRefilable < ActiveRecord::Base
	belongs_to :user
  belongs_to :evaluation_refilable

  validates_uniqueness_of :user_id, scope: :evaluation_id
  validates_presence_of :points
  validates_numericality_of :points, greater_than_or_equal_to: 0
end
