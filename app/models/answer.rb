class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  belongs_to :rubric
  has_many :comments

  validates_presence_of :answer_text
end
