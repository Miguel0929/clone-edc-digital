class QuizAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :quiz_question

  def self.respuesta(quiz_question, user)
    respuesta = '' 
    my_answers = where(quiz_question_id: quiz_question, user_id: user)
    my_answers.each_with_index do |answers, index|
      if my_answers.count == 1
        respuesta += answers.answer_text + " "
      elsif my_answers.count > 1
        if index < my_answers.count-1 
          respuesta += answers.answer_text + " / "
        else
          respuesta += answers.answer_text + " "
        end
      end   
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

  def self.proporcion(quiz_question, user)
    good, total = 0, 0
    where(quiz_question_id: quiz_question, user_id: user).each do |answers|
      good += answers.correct == true ? 1 : 0
      total += 1
    end
    if good == total
      return "<span class='text-success bold'><i class='fa fa-check p-r-5'></i>Correcto</span>"
    else
      if total > 1
        return "<span class='text-primary bold'>#{good} de #{total} aciertos</span>"
      else
        return "<span class='text-primary bold'>Incorrecto</span>"
      end
    end
  end

  def self.obtenido(quiz_question, user)
    obtenido = 0
    result = where(quiz_queston_id: quiz_question, user_id: user)
    result.each do |answer|
      obtenido += answer.correct == true ? answer.quiz_question.points.to_i / result.count : 0 
    end
  end
end
