class ProgressPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor_or_profesor
  before_action :set_group, only: [:show]

  helper_method :get_program_progress_strata
  helper_method :get_group_progress_strata
  helper_method :get_all_group_progress_strata
  helper_method :get_program_group_progress_strata

  add_breadcrumb "EDC DIGITAL", :root_path

  def index
  	add_breadcrumb "<a class='active' href='#{progress_panel_index_path}'>Panel de progreso de EDC Digital</a>".html_safe
    if current_user.admin?
      @users = User.students.all
      programs = Program.all
    elsif current_user.mentor? || current_user.profesor?
      @users = User.joins(:group).where(:groups => {id: current_user.groups.pluck(:id)}).where(role: 0)
      programs = get_user_programs
    end
  	if params[:group].present?
  		redirect_to progress_panel_path(params[:group].to_i)
    end
    if params[:category].present?
      @users =  User.students.joins(:group).where(groups: {category: params[:category]})
  	end

    @active_users = @users.where.not(invitation_accepted_at: nil)
    @inactive_users = @users.where(invitation_accepted_at: nil).count
    @hundred = @active_users.where("user_progress > ?", 70.0).count 
    @seventy = @active_users.where("user_progress <= ?", 70.0).where("user_progress > ?", 50.0).count
    @fifty = @active_users.where("user_progress <= ?", 50.0).where("user_progress > ?", 30.0).count 
    @thirty = @active_users.count - (@fifty + @seventy + @hundred)

    #Obtener "Distribución de avances por programa"
    @progress_per_program = []
    if params[:category].present?
      programs.each do |program|
        program_stat = get_program_progress_strata(program, params[:category], current_user.user_groups.pluck(:id))
        @progress_per_program.push({id: program.id, name: program.name, hundred: program_stat[0], seventy: program_stat[1], fifty: program_stat[2], thirty: program_stat[3], sumatory: program_stat.inject(0){|sum,x| sum + x }})
      end
    else
      programs.each do |program|
        program_stat = get_program_progress_strata(program, 0, current_user.user_groups.pluck(:id))
        @progress_per_program.push({id: program.id, name: program.name, hundred: program_stat[0], seventy: program_stat[1], fifty: program_stat[2], thirty: program_stat[3], sumatory: program_stat.inject(0){|sum,x| sum + x }})
      end
    end
  end

  def show
  	add_breadcrumb "<a class='active' href='#{progress_panel_index_path}'>Progreso de grupo: #{@group.name}</a>".html_safe
  	if params[:group].present?
  		redirect_to progress_panel_path(params[:group].to_i)
  	end
  	users = @group.students.all
  	@hundred, @seventy, @fifty, @thirty = 0, 0, 0, 0

  	# Para este punto los stats solo se han generado para usuarios activos en StudentsProgressJob
    @active_users = users.where.not(invitation_accepted_at: nil)
    @inactive_users = users.where(invitation_accepted_at: nil).count
    @hundred = @active_users.where("user_progress > ?", 70.0).count 
    @seventy = @active_users.where("user_progress <= ?", 70.0).where("user_progress > ?", 50.0).count
    @fifty = @active_users.where("user_progress <= ?", 50.0).where("user_progress > ?", 30.0).count 
    @thirty = @active_users.count - (@fifty + @seventy + @hundred)

    #Obtener "Distribución de avances por programa"
    @progress_per_program_per_group = []
    @group.all_programs.each do |program|
      program_stat = get_group_progress_strata(@group, program)
      @progress_per_program_per_group.push({name: program.name, hundred: program_stat[0], seventy: program_stat[1], fifty: program_stat[2], thirty: program_stat[3], sumatory: program_stat.inject(0){|sum,x| sum + x }})
    end
  end

  def progress_groups
  	add_breadcrumb "<a class='active' href='#{progress_panel_groups_path}'>Panel de progreso por grupos</a>".html_safe
    @groups = current_user.user_groups
  end

  def program_detail
    add_breadcrumb "<a class='active' href='#{ progress_per_program_path }'>Panel de progreso de programa</a>".html_safe
    program = params[:requested_program]
    stats = ProgramStat.where(program_id: program)
    lpaths = LearningPath.joins(:learning_path_contents).where(:learning_path_contents => {content_type: "Program", content_id: program}).pluck(:id)
    if current_user.admin?
      groups_program = Group.joins(:programs).where(:programs => {id: program}).pluck(:id)
      groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}).pluck(:id)
      @groups = Group.where(id: (groups_program + groups_path).uniq)
      students_with_group = User.where(role: 0, group_id: @groups.pluck(:id))
      students_no_group = User.includes(:program_stats).where(:program_stats => {user_id: stats.pluck(:user_id)}, group_id: nil)
      @active_users = students_with_group.where.not(invitation_accepted_at: nil).pluck(:id).uniq + students_no_group.where.not(invitation_accepted_at: nil).pluck(:id).uniq    
      @inactive_users = (students_with_group.count +  students_no_group.count) - @active_users.count
    elsif current_user.mentor?
      my_groups = current_user.user_groups.pluck(:id)
      groups_program = Group.where(id: my_groups).joins(:programs).where(:programs => {id: program}).pluck(:id)
      groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}, id: my_groups).pluck(:id)
      @groups = Group.where(id: (groups_program + groups_path).uniq)
      @active_users = User.where(role: 0, group_id: @groups.pluck(:id)).where.not(invitation_accepted_at: nil)
      @inactive_users = User.where(role: 0, group_id: @groups.pluck(:id)).where(invitation_accepted_at: nil).count
    end
    # Para este punto los stats solo se han generado para usuarios activos en StudentsProgressJob
    @hundred = stats.where(user_id: @active_users).where("program_progress > ?", 70.0).count 
    @seventy = stats.where(user_id: @active_users).where("program_progress <= ?", 70.0).where("program_progress > ?", 50.0).count
    @fifty = stats.where(user_id: @active_users).where("program_progress <= ?", 50.0).where("program_progress > ?", 30.0).count 
    @thirty = @active_users.count - (@fifty + @seventy + @hundred)
    # Para referencia, la siguiente línea muestra un ejemplo de un nested joins:
    # @groups = Group.joins(:students => :program_stats).where(program_stats: {program_id: params[:requested_program]}).uniq
  end

  def massive_program_progress
  	#@users = User.students.joins(:group)
  	total_jobs = 0
  	Group.all.each do |group|
  		puts total_g = group.students.count
  		puts total_p = group.all_programs.count
  		puts total_jobs = (total_p * total_g) + total_jobs
  	end

  	@job = AsyncJob.create({title: 'Actualizando progresos', progress: 0, total: total_jobs})
  	StudentsProgressJob.perform_async(@job.id)
    redirect_to progress_updater_path(@job)
  end

  private
  def get_program_progress_strata(program, category, my_groups)
    lpaths = LearningPath.joins(:learning_path_contents).where(:learning_path_contents => {content_type: "Program", content_id: program.id}).pluck(:id)
    if current_user.mentor? || (category.is_a? String)
      if category == 0
        groups_program = Group.where(id: my_groups).joins(:programs).where(:programs => {id: program.id}).pluck(:id)
        groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}, id: my_groups).pluck(:id)
        groups = Group.where(id: (groups_program + groups_path).uniq)
      elsif category.is_a? String
        groups_program = Group.where(category: category, id: my_groups).joins(:programs).where(programs: {id: program.id})
        groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}, id: my_groups, category: category).pluck(:id)
        groups = Group.where(id: (groups_program + groups_path).uniq)
      end
      stats = ProgramStat.where(user_id: User.where(group_id: groups.pluck(:id)).pluck(:id), program_id: program.id)
      students_count = User.where(group_id: groups.pluck(:id), role: 0).where.not(invitation_accepted_at: nil).count
    else
      stats = ProgramStat.where(program_id: program.id)
      groups_program = Group.joins(:programs).where(:programs => {id: program.id}).pluck(:id)
      groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}).pluck(:id)
      groups = Group.where(id: (groups_program + groups_path).uniq).pluck(:id)
      students_with_group = User.where(role: 0, group_id: groups).where.not(invitation_accepted_at: nil)
      students_no_group = User.includes(:program_stats).where(:program_stats => {user_id: stats.pluck(:user_id)}, group_id: nil).where.not(invitation_accepted_at: nil)
      students_count = students_with_group.count + students_no_group.count
      stats =  stats.where(user_id: (students_with_group.pluck(:id) + students_no_group.pluck(:id)).uniq)
    end
    hundred = stats.where("program_progress > ?", 70.0).count 
    seventy = stats.where("program_progress <= ?", 70.0).where("program_progress > ?", 50.0).count
    fifty = stats.where("program_progress <= ?", 50.0).where("program_progress > ?", 30.0).count 
    thirty = students_count - (fifty + seventy + hundred)    
  	return hundred, seventy, fifty, thirty
  end

  def get_group_progress_strata(group, program)
    active_students = group.students.where.not(invitation_accepted_at: nil).pluck(:id)
    stats = ProgramStat.where(program_id: program.id, user_id: active_students)
    hundred = stats.where("program_progress > ?", 70.0).count 
    seventy = stats.where("program_progress <= ?", 70.0).where("program_progress > ?", 50.0).count
    fifty = stats.where("program_progress <= ?", 50.0).where("program_progress > ?", 30.0).count 
    thirty = active_students.count - (fifty + seventy + hundred)
    return hundred, seventy, fifty, thirty
  end

  def get_all_group_progress_strata(group)
    active_users = group.students.where.not(invitation_accepted_at: nil)
    hundred = active_users.where("user_progress > ?", 70.0).count 
    seventy = active_users.where("user_progress <= ?", 70.0).where("user_progress > ?", 50.0).count
    fifty = active_users.where("user_progress <= ?", 50.0).where("user_progress > ?", 30.0).count 
    thirty = active_users.count - (fifty + seventy + hundred)
    return hundred, seventy, fifty, thirty
  end

  def get_program_group_progress_strata(group, selected_program)
    active_students = group.students.where.not(invitation_accepted_at: nil).pluck(:id)
    stats = ProgramStat.where(program_id: selected_program, user_id: active_students)
    hundred = stats.where("program_progress > ?", 70.0).count 
    seventy = stats.where("program_progress <= ?", 70.0).where("program_progress > ?", 50.0).count
    fifty = stats.where("program_progress <= ?", 50.0).where("program_progress > ?", 30.0).count 
    thirty = active_students.count - (fifty + seventy + hundred)
    return hundred, seventy, fifty, thirty
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def get_user_programs
    my_groups = current_user.user_groups.pluck(:id)
    group_programs = Program.joins(:group_programs).where(:group_programs => {group_id: my_groups}).pluck(:id)
    lpaths = LearningPath.joins(:groups).where(:groups => {id: my_groups}).pluck(:id)
    lcontents = LearningPathContent.joins(:learning_path).where(:learning_paths => {id: lpaths}, content_type: "Program").pluck(:content_id)
    return Program.where(id: (group_programs + lcontents).uniq)
  end
end
