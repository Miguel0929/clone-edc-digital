class MentorsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_state]

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentors_path}'>Mentores</a>".html_safe

    @users = Mentor.all.includes(:groups)
  end

  def show
    add_breadcrumb "Mentores", :mentors_path
    add_breadcrumb "<a class='active' href='#{mentor_path(@user)}'>#{@user.email}</a>".html_safe
    @groups = @user.groups
    @students = User.joins(:group).where(:groups => {id: @groups.pluck(:id)}, role: 0)
  end

  def edit
    add_breadcrumb "Mentores", :mentors_path
    add_breadcrumb @user.email, mentor_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_mentor_path(@user)}'>Editar información</a>".html_safe
  end

  def update
    @user.__elasticsearch__.update_document
    if @user.update(user_params)
      redirect_to mentors_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to mentors_path
  end
  
  def change_state
    if @user.banned?
      @user.unbann!
    else
      @user.bann!
    end

    redirect_to mentor_path(@user)
  end

  private
  def set_user
    @user = Mentor.find(params[:id])
  end

  def user_params
    params.require(:mentor).permit(:first_name, :last_name, :email, :phone_number, :group_id ,:role, group_ids: [])
  end

  def validate_student
    redirect_to users_path unless @user.student?
  end
end
