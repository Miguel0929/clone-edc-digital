module KeyQuestionsHelper

  def key_questions_hash
    KeyQuestion.all.map{|kq| {program: Program.find( Chapter.find( kq.chapter_content.chapter.id ).program_id ).id, key: kq, question: Question.find(kq.coursable_id) } }
  end

  def clean_repeated_answers(quiz, user)
  	quiz.quiz_questions.each do |question|
  		if question.question_type == 'checkbox'
  			# Tomar todas las respuestas de esta pregunta y este usuario
  			answers = question.quiz_answers.where(user_id: user)
  			# Iniciar un loop a través de todas esas respuestas repetidas en el campo de answer_text
  			answers.select([:answer_text]).group(:answer_text).having("count(answer_text) > 1").each do |repeated|
  				# Guardar las respuestas repetidas en un query
  				repeated_ans = answers.where(answer_text: repeated.answer_text)
  				# Eliminar las respuestas más viejas de esa query, solo dejar la más nueva
  				repeated_ans.order(:created_at)[0..(repeated_ans.length - 2)].map{|r| r.destroy}
  			end
  		end
  	end
  end

end