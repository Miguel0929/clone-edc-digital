class QuizAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :quiz_question
end
