class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:students, :index, :show]
  before_action :require_mentor, only: [:students]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :analytics_program]
  before_action :validate_student, only: [:edit, :update]

  def index
    redirect_to mentors_users_path
  end

  def mentors
    @users = User.mentors

    render :index
  end

  def students
    @users = case current_user.role
     when 'admin'
      User.students
     when 'mentor'
       current_user.groups.map(&:students).flatten
    end

    render :index
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to users_path
  end

  def analytics_program
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number)
  end

  def validate_student
    redirect_to users_path unless @user.student?
  end
end
