class ProgressPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor
  before_action :set_group, only: [:show]

  helper_method :get_program_progress_strata
  helper_method :get_group_progress_strata
  helper_method :get_all_group_progress_strata
  helper_method :get_program_group_progress_strata

  add_breadcrumb "EDC DIGITAL", :root_path

  def index
  	add_breadcrumb "<a class='active' href='#{progress_panel_index_path}'>Panel de progreso de EDC Digital</a>".html_safe
    if current_user.admin?
      puts "es el admin we"
      @users = User.students.all
      programs = Program.all
    elsif current_user.mentor?
      puts "es el mentor we"
      @users = User.joins(:group).where(:groups => {id: current_user.groups.pluck(:id)}).where(role: 0)
      programs = get_user_programs
    end
  	if params[:group].present?
  		redirect_to progress_panel_path(params[:group].to_i)
    end
    if params[:category].present?
      @users =  User.students.joins(:group).where(groups: {category: params[:category]})
  	end
    #else
    #  @users = User.students.all
    #end

  	#programs = Program.all
  	#stats = ProgramStat.all
  	@hundred, @seventy, @fifty, @thirty = 0, 0, 0, 0
  	# Para este punto los stats solo se han generado para usuarios activos en StudentsProgressJob
    @active_users = @users.where.not(invitation_accepted_at: nil)
    @inactive_users = @users.where(invitation_accepted_at: nil).count

    @active_users.each do |active|
      average  = active.user_progress
      if average >= 70.0
        @hundred = @hundred + 1
      elsif average >= 50.0
        @seventy = @seventy + 1
      elsif average >= 30.0
        @fifty = @fifty + 1
      else
        @thirty = @thirty + 1
      end
    end
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

  	@users = @group.students.all
  	#stats = @users.map{|i| i.program_stats.map{|a| a.program_progress}}.flatten
  	@hundred, @seventy, @fifty, @thirty = 0, 0, 0, 0
  	# Para este punto los stats solo se han generado para usuarios activos en StudentsProgressJob
    @active_users = @users.where.not(invitation_accepted_at: nil)
    @inactive_users = @users.where(invitation_accepted_at: nil).count

    @active_users.each do |active|
      average  = active.user_progress
      if average >= 70.0
        @hundred = @hundred + 1
      elsif average >= 50.0
        @seventy = @seventy + 1
      elsif average >= 30.0
        @fifty = @fifty + 1
      else
        @thirty = @thirty + 1
      end
    end
    #Obtener "Distribución de avances por programa"
    @progress_per_program_per_group = []
    @group.all_programs.each do |program|
      program_stat = get_group_progress_strata(@group, program)
      @progress_per_program_per_group.push({name: program.name, hundred: program_stat[0], seventy: program_stat[1], fifty: program_stat[2], thirty: program_stat[3], sumatory: program_stat.inject(0){|sum,x| sum + x }})
    end
  end

  def progress_groups
  	add_breadcrumb "<a class='active' href='#{progress_panel_groups_path}'>Panel de progreso por grupos</a>".html_safe
  	@groups = Group.all
  end

  def program_detail
    add_breadcrumb "<a class='active' href='#{ progress_per_program_path }'>Panel de progreso de programa</a>".html_safe
    @users = User.joins(:program_stats).where(program_stats: {program_id: params[:requested_program]})
    @groups = Group.joins(:students => :program_stats).where(program_stats: {program_id: params[:requested_program]}).uniq
    @hundred, @seventy, @fifty, @thirty = 0, 0, 0, 0
    @active_users, @inactive_users = [], 0
    # Para este punto los stats solo se han generado para usuarios activos en StudentsProgressJob
    @users.each do |user|
      if user.status == 'Activo'
        @active_users << user
      elsif user.status == 'Inactivo'
        @inactive_users = @inactive_users + 1
      end
    end
    @active_users.each do |active|
      sum = []
      average = 0
      userstat = ProgramStat.find_by(user_id: active.id, program_id: params[:requested_program]).program_progress
      #userstat.each do |stat|
      #  current_progress = stat.program_progress
      #  if !current_progress.nil? then sum << current_progress end
      #end
      #average = sum.inject(0.0) { |adding, el| adding + el }.to_f / sum.size
      if !userstat.nil?
        if userstat >= 70.0
          @hundred = @hundred + 1
        elsif userstat >= 50.0
          @seventy = @seventy + 1
        elsif userstat >= 30.0
          @fifty = @fifty + 1
        else
          @thirty = @thirty + 1
        end
      else
        @thirty = @thirty + 1
      end
    end
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
    if current_user.mentor? || (category.is_a? String)
      if category == 0
        groups_program = Group.where(id: my_groups).joins(:programs).where(:programs => {id: program.id}).pluck(:id)
        lpaths = LearningPath.joins(:learning_path_contents).where(:learning_path_contents => {content_type: "Program", content_id: program.id}).pluck(:id)
        groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}, id: my_groups).pluck(:id)
        groups = Group.where(id: (groups_program + groups_path).uniq)
      elsif category.is_a? String
        groups_program = Group.where(category: category, id: my_groups).joins(:programs).where(programs: {id: program.id})
        lpaths = LearningPath.joins(:learning_path_contents).where(:learning_path_contents => {content_type: "Program", content_id: program.id}).pluck(:id)
        groups_path = Group.joins(:learning_path).where(:learning_paths => {id: lpaths}, id: my_groups, category: category).pluck(:id)
        groups = Group.where(id: (groups_program + groups_path).uniq)
      end
      stats = ProgramStat.where(user_id: User.where(group_id: groups.pluck(:id)).pluck(:id), program_id: program.id)
      students_count = User.where(group_id: groups.pluck(:id)).count
    else
      stats = ProgramStat.where(program_id: program.id)
      #groups = Group.joins(:students).where(:users => {id: stats.pluck(:user_id).uniq}).uniq
      students_count = stats.count #User.joins(:group).where(:groups => {id: groups}).count
    end

  	hundred, seventy, fifty, thirty = 0, 0, 0, 0
  	stats.each do |stat|
      current_progress = stat.program_progress
      if !current_progress.nil?
    		if stat.program_progress >= 70.0
    			hundred += 1
    		elsif stat.program_progress >= 50.0
    			seventy += 1
    		elsif stat.program_progress >= 30.0
    			fifty += 1
    		end
      end
  	end
    thirty = students_count - fifty - seventy - hundred
  	return hundred, seventy, fifty, thirty
  end

  def get_group_progress_strata(group, program)
	  hundred, seventy, fifty, thirty = 0, 0, 0, 0
    students = group.students.all
    stats = ProgramStat.where(program_id: program.id, user_id: students.pluck(:id))

    stats.each do |stat|
      current_progress = stat.program_progress
      if !current_progress.nil?
        if current_progress >= 70.0
          hundred += 1
        elsif current_progress >= 50.0
          seventy += 1
        elsif current_progress >= 30.0
          fifty += 1
        end
      end
    end

    thirty = students.count - hundred - seventy - fifty
    return hundred, seventy, fifty, thirty
  end

  def get_all_group_progress_strata(group)
    students = group.students.all
    hundred, seventy, fifty, thirty = 0, 0, 0, 0
      students.each do |student|
        average = student.user_progress
        if average >= 70.0
          hundred = hundred + 1
        elsif average >= 50.0
          seventy = seventy + 1
        elsif average >= 30.0
          fifty = fifty + 1
        else
          thirty = thirty + 1
        end
      end
    return hundred, seventy, fifty, thirty
  end

  def get_program_group_progress_strata(group, selected_program)
    students = group.students.all
    hundred, seventy, fifty, thirty = 0, 0, 0, 0
    students.each do |student|
      student_stats = 0.0
      current_stat = ProgramStat.find_by(program_id: selected_program, user_id: student.id)
      if !current_stat.nil?
        current_progress = current_stat.program_progress
        if !current_progress.nil? then student_stats = current_progress end
      end
      if student_stats >= 70.0
        hundred = hundred + 1
      elsif student_stats >= 50.0
        seventy = seventy + 1
      elsif student_stats >= 30.0
        fifty = fifty + 1
      else
        thirty = thirty + 1
      end
    end
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
