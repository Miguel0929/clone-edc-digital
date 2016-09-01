module ApplicationHelper
  def answer_to_array(question)
    @question_answers ||= question.answer_options.split("\n").map {|option| option.strip}
  end

  def answer_is_selected?(answers, answer)
    return false if answers.answer_text.nil?

    answers.answer_text.split('\n').include?(answer)
  end

  def image_for_rubric(criteria)
    case criteria
    when 'Deficiente'
      image_tag('rubensito-01.png', width: 50)
    when 'Regular'
      image_tag('rubensito-02.png', width: 50)
    when 'Bueno'
      image_tag('rubensito-04.png', width: 50)
    when 'Excelente'
      image_tag('rubensito-05.png', width: 50)
    end
  end
end
