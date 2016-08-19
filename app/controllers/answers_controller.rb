class AnswersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @answers =  @user.answers
  end

  def edit
    @user = User.find(params[:user_id])
    @answer = @user.answers.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @answer = @user.answers.find(params[:id])

    if @answer.update(answer_params)
      redirect_to user_answers_path(@user)
    else
      render :edit
    end
  end

  private
  def answer_params
    params.require(:answer).permit(:rubric_id)
  end
end
