class Quiz < ActiveRecord::Base
  has_many :quiz_questions, dependent: :delete_all
  has_many :group_quizzes
  has_many :groups, through: :group_quizzes
  validates_presence_of :name, :description
end
