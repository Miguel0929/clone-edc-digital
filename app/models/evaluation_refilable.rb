class EvaluationRefilable < ActiveRecord::Base
	belongs_to :template_refilable

	has_many :user_evaluation_refilables
  has_many :users, through: :user_evaluation_refilables

	validates_presence_of :name, :points
  validates_numericality_of :points, greater_than_or_equal_to: 0
end
