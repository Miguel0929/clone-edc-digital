class Dashboard::AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  before_action :validate_coursable_type
  before_action :build_question
  def new
    @answer = build_answer
  end

  def create
    @answer = @question.answers.new(answer_params)

    @answer.user = current_user

    @answer.answer_text = sanitize_answer if @question.checkbox?

    if @answer.save
      redirect_to dashboard_program_path(@chapter_content.chapter.program)
    else
      render :new
    end
  end

  def update
    @answer = Answer.find(params[:id])

    @answer.answer_text = sanitize_answer if @question.checkbox?

    @answer.assign_attributes(answer_params)

    if @answer.save
      redirect_to dashboard_program_path(@chapter_content.chapter.program)

    else
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
