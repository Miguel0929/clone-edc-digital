module ApplicationHelper
  def answer_to_array(question)
    @question_answers ||= question.answer_options.split("\n").map {|option| option.strip}
  end
  
  def answer_to_select(question, detail)
    if detail
      question.answer_options.split("\n").map { |option| [ option.strip, option.strip ]}
    else
      question.answer_options.split("\n").map { |option| [ option.split('~')[0].strip, option.strip ]}
    end
  end

  def answer_is_selected?(answers, answer)
    return false if answers.answer_text.nil?
    answers.answer_text.split('\n').include?(answer)
  end

  def quiz_answer_selected?(answers, answer)
    return false if answers.answer_text.nil?
    answer.include?(answers.answer_text)
  end

  def points_quiz_question(question, user)
    total = 0
    if question.question_type == 'checkbox'
      answers = QuizAnswer.where(quiz_question_id: question.id, user_id: user.id) 
      answers.each do |answer|
        total += (question.points / answers.count) if answer.correct == true && !answer.nil?
      end
    else
      answer = QuizAnswer.find_by(quiz_question_id: question.id, user_id: user.id)
      !answer.nil? && answer.correct == true ? total += question.points : 0
    end
    return total
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
  
  def answer_to_show(user, question)
    answer = Answer.find_by(user_id: user.id, question_id: question.id)
    answer.nil? ? '' : answer.answer_text 
  end

  def parse_lesson_content(lesson)
    return lesson.content.gsub('{{video}}', '') if lesson.video_url.nil? || lesson.video_url.empty?

    lesson.content.gsub('{{video}}', content_tag(:div, lesson.video_url.html_safe, class: 'embed-responsive embed-responsive-16by9')) #Estas clases se pueden agregar para hacer la ventana del video más pequeña: col-sm-10 col-sm-offset-1 embed-col-10 
  end

  def include_margin?(controller_name, action_name)
    #controller_name == 'programs' && action_name == 'show'
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
