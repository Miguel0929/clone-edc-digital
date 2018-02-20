class ProfesorsController < ApplicationController
	before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_state]

  add_breadcrumb "EDC DIGITAL", :root_path
  def index
  	add_breadcrumb "<a class='active' href='#{profesors_path}'>Profesores</a>".html_safe
  	@users = Profesor.all
  end

  def show
  	add_breadcrumb "Profesores", :profesors_path
    add_breadcrumb "<a class='active' href='#{profesors_path(@user)}'>#{@user.email}</a>".html_safe
    @groups = @user.groups
    @students = User.joins(:group).where(:groups => {id: @groups.pluck(:id)}, role: 0)
  end

  def edit
  	add_breadcrumb "Profesores", :profesors_path
    add_breadcrumb @user.email, profesor_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_profesor_path(@user)}'>Editar información</a>".html_safe
  end

  def update
    @user.__elasticsearch__.update_document
    if @user.update(user_params)
      redirect_to profesors_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to profesors_path
  end

  def change_state
    if @user.banned?
      @user.unbann!
    else
      @user.bann!
    end

    redirect_to profesor_path(@user)
  end	


  private
  def set_user
    @user = Profesor.find(params[:id])
  end
  def user_params
    params.require(:profesor).permit(:first_name, :last_name, :email, :phone_number, :role, group_ids: [])
  end	
end
