class Evaluation < ActiveRecord::Base
  belongs_to :chapter

  has_many :user_evaluations
  has_many :users, through: :user_evaluations

  validates_presence_of :name, :points
  validates_numericality_of :points, greater_than_or_equal_to: 0
end
