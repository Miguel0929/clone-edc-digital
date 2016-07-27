module ApplicationHelper
  def answer_to_array(question)
    @question_answers ||= question.answer_options.split("\n").map {|option| option.strip}
  end

  def answer_is_selected?(answers, answer)
    return false if answers.answer_text.nil?

    answers.answer_text.split('\n').include?(answer)
  end
end
