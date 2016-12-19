class Evaluation < ActiveRecord::Base
  belongs_to :chapter

  validates_presence_of :name, :points
  validates_numericality_of :points, greater_than_or_equal_to: 0
end
