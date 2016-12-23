class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_program
  before_action :answer_is_not_present, only: [:update]

  def index
    question_ids = Question.select('questions.id')
    .joins('INNER JOIN chapter_contents on questions.id = chapter_contents.coursable_id')
    .where('chapter_contents.chapter_id in (?) and chapter_contents.coursable_type = ?', @program.chapters.pluck(:id), 'Question')

    @answers = Answer.includes(:rubric)
    .select("answers.*, questions.question_text")
    .joins(:question)
    .where('answers.question_id in (?) and answers.user_id = ?', question_ids, @user.id)
    .group('questions.id')
    .group('answers.id')
  end

  def edit
    @answer = @user.answers.find(params[:id])
  end

  def update
    if @answer.update(answer_params)
      create_notification
      redirect_to user_program_answers_path(@user, @program)
    else
      render :edit
    end
  end

  private
  def answer_params
    params.require(:answer).permit(:rubric_id)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_program
    @program = Program.find(params[:program_id])
  end

  def answer_is_not_present
    @answer = @user.answers.find(params[:id])
    redirect_to edit_user_program_answer_path(@user, @program, @answer) unless params[:answer].present?
  end

  def create_notification
    @user.program_notifications.create(program: @program, notification_type: 'rubric')
  end
end
