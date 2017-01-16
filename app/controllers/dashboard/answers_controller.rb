class Dashboard::AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  before_action :validate_coursable_type
  before_action :build_question

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path

  def router
    answer = build_answer

    if answer.new_record?
      redirect_to new_dashboard_chapter_content_answer_path(@chapter_content)
    else
      redirect_to dashboard_chapter_content_answer_path(@chapter_content, answer)
    end
  end

  def show
    @answer = Answer.find(params[:id])
    ahoy.track "Viewed content", chapter_content_id: @chapter_content.id

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe
  end

  def new
    @answer = build_answer
    ahoy.track "Viewed content", chapter_content_id: @chapter_content.id

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe
  end

  def create
    @answer = @question.answers.new(answer_params)

    @answer.user = current_user

    @answer.answer_text = sanitize_answer if @question.checkbox?

    if @answer.save
      redirect_to dashboard_chapter_content_answer_path(@chapter_content, @answer), notice: "Cambios guardados con éxito"
    elsif @answer.errors[:user_id].empty? == false
      redirect_to dashboard_chapter_content_answer_path(@chapter_content, Answer.find_by(user: @answer.user, question: @answer.question))
    else
      add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
      add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe

      render :new
    end
  end

  def edit
    @answer = Answer.find(params[:id])

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe
  end

  def update
    @answer = Answer.find(params[:id])

    @answer.answer_text = sanitize_answer if @question.checkbox?

    @answer.assign_attributes(answer_params)

    if @answer.save
      ahoy.track "Answer updated", answer_id: @answer.id

      redirect_to dashboard_chapter_content_answer_path(@chapter_content, @answer), notice: "Cambios guardados con éxito"
    else
      add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
      add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe

      render :new
    end

  end

  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end

  def validate_coursable_type
    redirect_to root_url unless @chapter_content.coursable_type == 'Question'
  end

  def build_question
    @question = @chapter_content.model
  end

  def build_answer
    @question.answers.find_by(user: current_user, question: @question) || @question.answers.new(user: current_user)
  end

  def answer_params
    params.require(:answer).permit(:user_id, :question_id, :answer_text)
  end

  def sanitize_answer
    params[:answer][:answer_text].join('\n') if params[:answer][:answer_text].present?
  end
end
