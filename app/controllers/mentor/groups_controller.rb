class Mentor::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentor_groups_path}'>Grupos</a>".html_safe
    @groups = current_user.groups.includes(:programs, :users)
  end

  def show
    @group = current_user.groups.includes(:programs, :users, :active_students).find(params[:id])

    add_breadcrumb "Grupos", :mentor_groups_path
    add_breadcrumb "<a class='active' href='#{mentor_group_path(@group)}'>#{@group.name}</a>".html_safe
  end
end
