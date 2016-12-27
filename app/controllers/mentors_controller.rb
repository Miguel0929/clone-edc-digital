class MentorsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentors_path}'>Mentores</a>".html_safe

    @users = Mentor.all
  end

  def show
    add_breadcrumb "Mentores", :mentors_path
    add_breadcrumb "<a class='active' href='#{mentor_path(@user)}'>#{@user.email}</a>".html_safe
  end

  def edit
    add_breadcrumb "Mentores", :mentors_path
    add_breadcrumb @user.email, mentor_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_mentor_path(@user)}'>Editar información</a>".html_safe
  end

  def update
    add_breadcrumb "Mentores", :mentors_path
    add_breadcrumb @user.email, mentor_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_mentor_path(@user)}'>Editar información</a>".html_safe

    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to mentors_path
  end

  private
  def set_user
    @user = Mentor.find(params[:id])
  end

  def user_params
    params.require(:mentor).permit(:first_name, :last_name, :email, :phone_number)
  end

  def validate_student
    redirect_to users_path unless @user.student?
  end
end
