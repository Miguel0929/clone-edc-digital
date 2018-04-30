class Profesor::GroupsController < ApplicationController
	before_action :authenticate_user!
  before_action :require_profesor
  before_action :my_groups?, only: [:show]

  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{profesor_groups_path}'>Grupos</a>".html_safe
    @groups = current_user.groups.includes(:programs, :users).page(params[:page]).per(10)
    @groups = current_user.groups.group_search(params[:query]).page(params[:page]) if params[:query].present? 
  end

  def show
  	@group = current_user.groups.includes(:programs, :users, :active_students).find(params[:id])
    @students = @group.active_students.order(:id).page(params[:page]).per(20)
    @students = @group.student_search(params[:query]).page(params[:page]).per(20) if params[:query].present?
    add_breadcrumb "Grupos", :profesor_groups_path
    add_breadcrumb "<a class='active' href='#{mentor_group_path(@group)}'>#{@group.name}</a>".html_safe

    respond_to do |format|
      format.html
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="students_list.xlsx"'}
    end
  end	

  def my_groups?
    group = Group.find(params[:id])
    unless current_user.admin? || group.my_group?(current_user) then redirect_to profesor_groups_path, notice: "Este no es uno de tus grupos" end
  end
end
