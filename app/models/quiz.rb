class Quiz < ActiveRecord::Base
  has_many :quiz_questions, dependent: :delete_all
  has_many :group_quizzes
  has_many :groups, through: :group_quizzes
  validates_presence_of :name, :description

  def average(user)
    total = 0
    quiz_questions.each do |question|
    answer = QuizAnswer.find_by(quiz_question_id: question.id, user_id: user.id)
    if !answer.nil? && answer.correct
        total += question.points
      end
    end
    return total
  end
end
