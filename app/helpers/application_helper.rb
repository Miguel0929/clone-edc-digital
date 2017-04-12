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

  def parse_lesson_content(lesson)
    return lesson.content.gsub('{{video}}', '') if lesson.video_url.nil? || lesson.video_url.empty?

    lesson.content.gsub('{{video}}', content_tag(:div, lesson.video_url.html_safe, class: 'embed-responsive embed-responsive-16by9'))
  end

  def include_margin?(controller_name, action_name)
    controller_name == 'programs' && action_name == 'show'
  end

  def url_prod_helper(url)
    Rails.env.production? ? url.gsub('http', 'https') : url
  end
  
  def flash_class(level)
    case level.to_sym
      when :notice then "alert alert-success"
      when :info then "alert alert-info"
      when :alert then "alert alert-danger"
      when :warning then "alert alert-warning"
    end
  end
  def active_page(active_page)
    @active == active_page ? "active" : ""
  end 
end
