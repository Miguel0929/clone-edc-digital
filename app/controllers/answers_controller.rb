class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_program

  def index
    answers =  @user.answers
    @answers = answers.select { |answer| answer.question.chapter_content.chapter.program == @program }
  end

  def edit
    @answer = @user.answers.find(params[:id])
  end

  def update
    @answer = @user.answers.find(params[:id])

    if @answer.update(answer_params)
      binding.pry
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
end
