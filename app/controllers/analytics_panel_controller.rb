class AnalyticsPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor
  before_action :set_group, only: [:group]
  add_breadcrumb "EDCDIGITAL", :root_path

  helper_method :program_objects

  def index
  	add_breadcrumb "<a class='active' href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
  	if current_user.mentor?
  		@groups = current_user.groups
  		@programs = Program.includes(:group_programs).where(:group_programs => {group_id: @groups})
  		#@active_students = User.where(group_id: @groups, role: 0).where.not(invitation_accepted_at: nil)
  		#@inactive_students = User.where(group_id: @groups, role: 0).where(invitation_accepted_at: nil)
  	elsif current_user.admin?
  		@groups = Group.all
  		@programs = Program.all
  		#@active_students = User.where(role: 0).where.not(invitation_accepted_at: nil)
  		#@inactive_students = User.where(role: 0).where(invitation_accepted_at: nil)
  	end
  end

  def group
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{group_analytics_panel_path(@group)}'>Progreso de grupo</a>".html_safe
    user = current_user
    @groups = current_user.groups
    if @group
      #@group = Group.find(params[:group])
      @programs = Program.joins(:group_programs).where(group_programs: {group_id: @group}).order(:name)
      @students = User.where(group: @group, role: 0).where.not(invitation_accepted_at: nil).uniq.order(:first_name)
      #@students = User.joins(:program_stats).where(group: groups, role: 0).uniq
    end
  end

  private
  def set_group
    @group = Group.find(params[:id])
  end

  def program_objects(program)
  	#program_groups = @groups.includes(:group_programs).where(:group_programs => {program_id: program})
    program_groups = program.all_groups(current_user)
  	my_students = User.where(group_id: program_groups.pluck(:id), role: 0).where.not(invitation_accepted_at: nil)
  	actives = my_students.count
  	checked = my_students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program}).count
  	return [program_groups, actives, checked]
  end
end