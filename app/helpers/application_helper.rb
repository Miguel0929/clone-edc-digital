module ApplicationHelper
  def answer_to_array(question)
    @question_answers ||= question.answer_options.split("\n").map {|option| option.strip}
  end

  def answer_is_selected?(answers, answer)
    return false if answers.answer_text.nil?

    answers.answer_text.split('\n').include?(answer)
  end

  def image_for_rubric(criteria, style='')
    case criteria
    when 'Deficiente'
      'rubensito-01.png'
    when 'Regular'
      'rubensito-02.png'
    when 'Bueno'
      'rubensito-04.png'
    when 'Excelente'
      'rubensito-05.png'
    end
  end
end
