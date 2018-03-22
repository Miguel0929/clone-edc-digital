module KeyQuestionsHelper

  def key_questions_hash
    KeyQuestion.all.map{|kq| {program: Program.find( Chapter.find( kq.chapter_content.chapter.id ).program_id ).id, key: kq, question: Question.find(kq.coursable_id) } }
  end

end