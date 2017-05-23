module EvaluationHelper
  def answered_questions(chapter, user)
    total = 0
    chapter.questions.each do |question|
      unless Answer.where(question_id: question.id, user_id: user.id).empty?
        total += 1
      end
    end
    total
  end

  def total_qustions(programs)
    total = 0
    programs.each do |program|
      total += program.questions.count
    end   
    total
  end
end
