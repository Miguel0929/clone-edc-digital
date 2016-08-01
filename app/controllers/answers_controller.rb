class AnswersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @answers =  @user.answers
  end
end
