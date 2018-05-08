class Mentor::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :my_groups?, only: [:show, :inactive_students, :template_refilables, :quizzes]
  include GroupHelper

  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentor_groups_path}'>Grupos</a>".html_safe
    @groups = current_user.groups.includes(:programs, :users).page(params[:page]).per(10)
    @groups = current_user.groups.group_search(params[:query]).page(params[:page]) if params[:query].present? 
  end

  def codes
    @group=current_user.groups.includes(:programs, :users, :active_students).find(params[:id])
  end  

  def show
    @group = current_user.groups.includes(:programs, :users, :active_students).find(params[:id])
    @students = @group.active_students.order(:id).page(params[:page]).per(20)
    @students = @group.student_search(params[:query]).page(params[:page]).per(20) if params[:query].present?
    @programs = sort_programs(@group, @group.all_programs) rescue []
    add_breadcrumb "Grupos", :mentor_groups_path
    add_breadcrumb "<a class='active' href='#{mentor_group_path(@group)}'>#{@group.name}</a>".html_safe

    respond_to do |format|
      format.html
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="students_list.xlsx"'}
    end
  end

  def template_refilables
    @group = current_user.groups.includes(:users, :active_students).find(params[:id])
    @students = @group.active_students.order(:id).page(params[:page]).per(20)
    @students = @group.student_search(params[:query]).page(params[:page]).per(20) if params[:query].present?
    @template_refilables = sort_template_refilables(@group)
    add_breadcrumb "Grupos", :mentor_groups_path
    add_breadcrumb "<a class='active' href='#{mentor_group_path(@group)}'>#{@group.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{template_refilables_mentor_group_path(@group)}'>Plantillas</a>".html_safe
  end

  def quizzes
    @group = current_user.groups.includes(:users, :active_students).find(params[:id])
    @students = @group.active_students.order(:id).page(params[:page]).per(20)
    @students = @group.student_search(params[:query]).page(params[:page]).per(20) if params[:query].present?
    @quizzes = sort_quizzes(@group)
    add_breadcrumb "Grupos", :mentor_groups_path
    add_breadcrumb "<a class='active' href='#{mentor_group_path(@group)}'>#{@group.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{quizzes_mentor_group_path(@group)}'>Examenes</a>".html_safe
  end   

  def inactive_students
    group = Group.find(params[:id])
    @inactives = User.where(group_id: group.id, role: 0, invitation_accepted_at: nil)
    add_breadcrumb "<a href='#{mentor_groups_path}'>Grupos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{inactive_students_mentor_group_path(group)}'>Usuarios inactivos de #{group.name}</a>".html_safe
  end

  def my_groups?
    group = Group.find(params[:id])
    unless current_user.admin? || group.my_group?(current_user) then redirect_to mentor_groups_path, notice: "Este no es uno de tus grupos" end
  end

end
