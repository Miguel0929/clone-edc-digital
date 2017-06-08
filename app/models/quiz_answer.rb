class QuizAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :quiz_question

  def self.respuesta(quiz_question, user)
    respuesta = '' 
    where(quiz_question_id: quiz_question, user_id: user).each do |answers|
      respuesta += answers.answer_text + " "
    end
    respuesta == '' ? 'Sin respuesta' : respuesta
  end

  def self.revisada(quiz_question, user)
    revisada = ''
    where(quiz_question_id: quiz_question, user_id: user).each do |answers|
      revisada += answers.correct == true ? "<span class='label label-success'>Correcto</span> " : "<span class='label label-danger'>Incorrecto</span> "
    end
    revisada
  end

  def self.obtenido(quiz_question, user)
    obtenido = 0
    result = where(quiz_queston_id: quiz_question, user_id: user)
    result.each do |answer|
      obtenido += answer.correct == true ? answer.quiz_question.points.to_i / result.count : 0 
    end
  end
end
