class Dashboard::QuizProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  helper_method :right_answer
  helper_method :evaluating_quiz
  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path

  def router
    quiz=@chapter_content.model
    if !@chapter_content.model.answered?(current_user)
      redirect_to new_dashboard_chapter_content_quiz_program_path(@chapter_content)
    else
      redirect_to dashboard_chapter_content_quiz_program_path(@chapter_content, quiz)
    end
  end
  def new
    @quiz = @chapter_content.model
    @answers = []
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: current_user.id)
    end
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end

  def create
    params[:answers].each_with_index do |answer, index|
      answer_text = answer[1][:answer_text]
        if answer_text.class == Array

          answer_text.each do |a|
            answer[1][:correct] = a.split(' ~ ')[1] == 'correcta' ? true : false
            answer[1][:answer_text] = a.split(' ~ ')[0]
            QuizAnswer.create(answer_params(answer))
          end
        else
          answer[1][:correct] = answer[1][:answer_text].split(' ~ ')[1] == 'correcta' ? true : false 
          answer[1][:answer_text] = answer[1][:answer_text].split(' ~ ')[0]  
          QuizAnswer.create(answer_params(answer))
        end
    end
    redirect_to_next_content
  end 
  def show
    @quiz=@chapter_content.model
    ids = @quiz.quiz_questions.map{ |q| q.id }
    @answers = QuizAnswer.where(quiz_question_id: ids, user_id: current_user.id)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end 
  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end
  def answer_params(custom_params)
      ActionController::Parameters.new(custom_params[1]).permit(:user_id, :quiz_question_id, :answer_text, :correct)
  end
  def redirect_to_next_content
    program=@chapter_content.chapter.program
    mensaje= "Examen enviado con éxito"
    if @chapter_content.lower_item
      redirect_to dashboard_chapter_content_path(@chapter_content.lower_item), notice: mensaje
    elsif program.next_chapter(@chapter_content.chapter) && program.next_chapter(@chapter_content.chapter).chapter_contents.first
      redirect_to dashboard_chapter_content_path(program.next_chapter(@chapter_content.chapter).chapter_contents.first), notice: mensaje
    else
      redirect_to dashboard_program_path(program), notice: mensaje
    end
  end
  def evaluating_quiz(rightones, yours)
    result = nil
    rightones.each do |rightone|
      if rightone == yours
        result = true
        break
      else
        result = false
      end
    end
    return result
  end
  def right_answer(question)
    options = QuizQuestion.find(question).answer_options.split /[\r\n]+/
    righty = [];

    options.each do |option|
      if option.include? "~ correcta" then righty << option.chomp(" ~ correcta") end
    end
    return righty
  end

end
