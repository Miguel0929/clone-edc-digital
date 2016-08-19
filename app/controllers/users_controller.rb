class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = current_user.admin? ? User.all : User.students
  end
end
