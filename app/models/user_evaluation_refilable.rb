class UserEvaluationRefilable < ActiveRecord::Base
  belongs_to :user
  belongs_to :evaluation_refilable
  belongs_to :refilable

  #validates_uniqueness_of :user_id, scope: :evaluation_refilable_id
  validates_presence_of :points
  validates_numericality_of :points, greater_than_or_equal_to: 0

  def puntaje
  	(self.evaluation_refilable.points.to_f * (self.points.to_f/100)).round
  end	
end
