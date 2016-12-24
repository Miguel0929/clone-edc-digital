class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:students, :index, :show, :analytics_program]
  before_action :require_mentor, only: [:students, :analytics_program]
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
      User.students_table
     when 'mentor'
       User.where('id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
    end

    if params[:state].present?
      case params[:state]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)

        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    @users = @users.where(group: params[:group]) if params[:group].present?

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
    @program = Program.find(params[:program_id])
    @chapter_contents = ChapterContent.joins(chapter: [:program]).where('programs.id = ?', @program.id).order(position: :asc)
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :group_id)
  end

  def validate_student
    redirect_to users_path unless @user.student?
  end
end
