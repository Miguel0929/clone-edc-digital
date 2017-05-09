class Dashboard::QuizzesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    @quizzes = current_user.group.quizzes
  end
end
