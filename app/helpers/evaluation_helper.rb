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

  def seen_percentage_chapter(chapter, user)
    viewed = []
    chapter.chapter_contents.each do |content|
      viewed << !user.trackers.find_by(chapter_content_id: content).nil?
    end
    ones = viewed.count(true)
    percentage = ((ones.to_f / viewed.size.to_f) * 100).ceil
    return percentage
  end
end
