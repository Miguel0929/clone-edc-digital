class Quiz < ActiveRecord::Base
  has_many :quiz_questions, dependent: :delete_all
  has_many :group_quizzes, dependent: :nullify
  has_many :groups, through: :group_quizzes, dependent: :nullify
  validates_presence_of :name, :description

  enum tipo: [ :ruta, :complementario]

  def average(user)
    total = 0
    quiz_questions.each do |question|
    if question.question_type == 'checkbox'
      answers = QuizAnswer.where(quiz_question_id: question.id, user_id: user.id)
      answers.each do |answer|
        if !answer.nil? && answer.correct
          total += (question.points / answers.count)
        end
      end
    else
      answer = QuizAnswer.find_by(quiz_question_id: question.id, user_id: user.id)
      if !answer.nil? && answer.correct
          total += question.points
        end
      end
    end
    return total
  end

  def self.tipo_type_options
    [['Ruta de aprendizaje', 'ruta'], ['Complementario', 'complementario']]
  end

  def answered(user)
    ids = quiz_questions.map { |q| q.id }
    return QuizAnswer.where(quiz_question_id: ids, user_id: user.id).count
  end

  def answered?(user)
    ids = quiz_questions.map { |q| q.id }
    respuestas = QuizAnswer.where(quiz_question_id: ids, user_id: user.id).count
    preguntas=self.quiz_questions.count
    if respuestas > 0 && preguntas != 0
      return true
    else
      return false
    end  
  end  
end
