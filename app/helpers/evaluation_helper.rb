module EvaluationHelper
  def answered_questions(chapter, user)
    total = 0
    chapter.content_chapters.each do |content|
      content.questions.each do |question|
        unless Answer.where(question_id: question.id, user_id: user.id).empty?
          total += 1
        end
      end
    end
    chapter.questions.each do |question|
      unless Answer.where(question_id: question.id, user_id: user.id).empty?
        total += 1
      end
    end
    total
  end

  def total_qustions(chapters)
    total = 0
    chapters.each do |chapter|
      chapter.content_chapters.each do |content|
        total += content.questions.count
      end  
      total += chapter.questions.count
    end   
    total
  end

  def seen_percentage_chapter(chapter, user)
    viewed = chapter.chapter_contents.map{|content| !content.trackers.find_by(user_id: user).nil?}.flatten
    ones = viewed.count(true)
    if viewed.size > 0
      percentage = ((ones.to_f / viewed.size.to_f) * 100).ceil
    else
      percentage = 0.0
    end
    return percentage
  end
end
