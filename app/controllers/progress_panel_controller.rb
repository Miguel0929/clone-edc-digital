class ProgressPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor
  before_action :set_group, only: [:show]

  helper_method :get_program_progress_strata
  helper_method :get_group_progress_strata
  helper_method :get_all_group_progress_strata

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
  	add_breadcrumb "<a class='active' href='#{progress_panel_index_path}'>Panel de progreso de EDC Digital</a>".html_safe
  	if params[:group].present?
  		redirect_to progress_panel_path(params[:group].to_i)
  	end
  	@users = User.students.all
  	@programs = Program.all
  	stats = ProgramStat.all
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
      userstat = ProgramStat.where(user_id: active.id)
      userstat.each do |stat|
        sum << stat.program_progress
      end
      average = sum.inject(0.0) { |adding, el| adding + el }.to_f / sum.size
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
  	#stats.each do |stat|
  	#	if stat.program_progress >= 70.0
  	#		@hundred = @hundred + 1
  	#	elsif stat.program_progress >= 50.0
  	#		@seventy = @seventy + 1
  	#	elsif stat.program_progress >= 30.0
  	#		@fifty = @fifty + 1
  	#	else
  	#		@thirty = @thirty + 1
  	#	end		
  	#end
  	#@active_users, @inactive_users = 0, 0
  	#User.students.all.each do |student|
  	#	if student.status == 'Activo'
  	#		@active_users = @active_users + 1
  	#	elsif student.status == 'Inactivo'
  	#		@inactive_users = @inactive_users + 1
  	#	end
  	#end
  end

  def show
  	add_breadcrumb "<a class='active' href='#{progress_panel_index_path}'>Progreso de grupo: #{@group.name}</a>".html_safe
  	if params[:group].present?
  		redirect_to progress_panel_path(params[:group].to_i)
  	end
  	@users = @group.students.all
  	#stats = @users.map{|i| i.program_stats.map{|a| a.program_progress}}.flatten
  	@hundred, @seventy, @fifty, @thirty = 0, 0, 0, 0
    @active_users, @inactive_users = [], 0
  	# Para este punto los stats solo se han generado para usuarios activos en StudentsProgressJob
    @users.all.each do |student|
      if student.status == 'Activo'
        @active_users << student
      elsif student.status == 'Inactivo'
        @inactive_users = @inactive_users + 1
      end
    end
    @active_users.each do |active|
      sum = []
      average = 0
      userstats = ProgramStat.where(user_id: active.id)
      userstats.each do |stat|
        sum << stat.program_progress
      end
      average = sum.inject(0.0) { |adding, el| adding + el }.to_f / sum.size
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
  end

  def progress_groups
  	add_breadcrumb "<a class='active' href='#{progress_panel_groups_path}'>Panel de progreso por grupos</a>".html_safe
  	@groups = Group.all
  end

  def massive_program_progress
  	#@users = User.students.joins(:group)
  	total_jobs = 0
  	Group.all.each do |group|
  		puts total_g = group.students.count 
  		puts total_p = group.programs.count 
  		puts total_jobs = (total_p * total_g) + total_jobs
  	end
  	
  	@job = AsyncJob.create({title: 'Actualizando progresos', progress: 0, total: total_jobs})
  	StudentsProgressJob.perform_async(@job.id)
    redirect_to progress_updater_path(@job)
  end

  private
  def get_program_progress_strata(program)
  	stats = ProgramStat.where(program_id: program)
  	hundred, seventy, fifty, thirty = 0, 0, 0, 0
  	stats.each do |stat|
  		if stat.program_progress >= 70.0
  			hundred += 1
  		elsif stat.program_progress >= 50.0
  			seventy += 1
  		elsif stat.program_progress >= 30.0
  			fifty += 1
  		else
  			thirty += 1
  		end		
  	end
  	return hundred, seventy, fifty, thirty
  end

  def get_group_progress_strata(group, program)
  	  hundred, seventy, fifty, thirty = 0, 0, 0, 0
      students = group.students.all
      students.each do |student|
        stat = ProgramStat.where(program_id: program.id, user_id: student.id).last
        if stat.program_progress >= 70.0
		  		hundred += 1
		  	elsif stat.program_progress >= 50.0
		  		seventy += 1
		  	elsif stat.program_progress >= 30.0
		  		fifty += 1
		  	else
		  		thirty += 1
		  	end	
      end
      return hundred, seventy, fifty, thirty
  end

  def get_all_group_progress_strata(group)
    students = group.students.all
    programs = group.programs.all
    hundred, seventy, fifty, thirty = 0, 0, 0, 0
      students.each do |student|
        student_stats = []
        average = 0
        programs.each do |program|
          student_stats << ProgramStat.where(program_id: program.id, user_id: student.id).last.program_progress
        end
        average = student_stats.inject(0.0) { |adding, el| adding + el }.to_f / student_stats.size
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
      #programs.each do |program|
      #  students.each do |student|
	    #    stat = ProgramStat.where(program_id: program.id, user_id: student.id).last
	    #    if stat.program_progress >= 70.0
		  #		  hundred += 1
			#  	elsif stat.program_progress >= 50.0
			#  		seventy += 1
			#  	elsif stat.program_progress >= 30.0
			#  		fifty += 1
			#  	else
			#  		thirty += 1
			#  	end	
      #  end
      #end
    return hundred, seventy, fifty, thirty
  end

  def set_group
    @group = Group.find(params[:id])
  end
end