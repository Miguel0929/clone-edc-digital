class Mentor::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  helper_method :get_group_stat

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentor_groups_path}'>Grupos</a>".html_safe
    @groups = current_user.groups.includes(:programs, :users).page(params[:page]).per(10)
    @groups = current_user.groups.group_search(params[:query]).page(params[:page]) if params[:query].present? 
  end

  def show
    @group = current_user.groups.includes(:programs, :users, :active_students).find(params[:id])
    @students = @group.active_students
    @students = @group.student_search(params[:query]) if params[:query].present?
    add_breadcrumb "Grupos", :mentor_groups_path
    add_breadcrumb "<a class='active' href='#{mentor_group_path(@group)}'>#{@group.name}</a>".html_safe

    respond_to do |format|
      format.html
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="students_list.xlsx"'}
    end
  end

  def get_group_stat(group)
    GroupStat.where(group_id: group.id).last
  end
end
