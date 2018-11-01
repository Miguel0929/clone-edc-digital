class AnalyticsPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor_or_profesor
  before_action :set_group, only: [:group]
  before_action :set_program, only: [:group_program]
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  include GroupHelper
  include EvaluationRefilablesHelper


  helper_method :program_objects

  def index
  	add_breadcrumb "<a class='active' href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
  	if current_user.mentor? || current_user.profesor?
      progs = []
  		current_user.groups.each do |group|
        group.all_programs.each do |program|
          progs << program
        end  
      end  
      @programs = Program.where(id: progs.uniq.reverse)

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
    @groups = (user.mentor? || user.profesor?) ? current_user.groups : Group.all
    @industries = Industry.all
    if @group
      if params[:industry].present? 
        @industry = Industry.find(params[:industry]).id
        @students = User.where(group: @group, role: 0, industry_id: @industry).where.not(invitation_accepted_at: nil).uniq.order(:first_name) 
      else 
        @industry = ""
        @students = User.where(group: @group, role: 0).where.not(invitation_accepted_at: nil).uniq.order(:first_name) 
      end
      @programs = sort_programs(@group, @group.all_programs)
      @pag_max = 100
      @records_number = @students.count
      @students = @students.page(params[:page]).per(@pag_max)
      #bienvenido_program = Program.where("name like ?", "%" + "¡Bienvenid" + "%").last
      #unless bienvenido_program.nil? 
      #  @bienvenido = bienvenido_program.chapters.where("name like ?", "%" + "Diagnóstico" + "%").last
      #else
      #  @bienvenido = nil
      #end
    end
    @grafica = [["Activos", @group.active_students.count],["Inactivos", @group.inactive_students.count]]
  end

  def group_program
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{group_program_analytics_panel_path(@program)}'>Estudientes evaluados en #{@program.name}</a>".html_safe
    grupos = Group.all
    @grafica = []
    grupos.each do |group|
      if group.all_programs.include?(@program) 
        students = group.active_students
        checked = students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: @program.id}).count
        @grafica << [group.name, checked]
      end   
    end 
  end 

  def create_students_evaluated
    
    @groups = Group.all
    @programs = Program.all.order(:id)
    c_programs = Program.count

    timestamp = Time.current.to_i
    emails = []
    redis = Redis.new
    redis.set("job_#{timestamp}", {
      total: c_programs,
      progress: 0
    }.to_json) 

    @programs.each do |program|
      AnalyticsJob.perform_async(program, @groups, "job_#{timestamp}")
    end
    flash[:notice] = "Calculando Avances"
    redirect_to students_evaluated_progress_analytics_panel_path(timestamp)  
  end

  def students_evaluated
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_evaluated_analytics_panel_index_path}'>Alumnos evaluados</a>".html_safe
    @programs = Program.all
    @states = State.all.order(:id)
    @total_alumnos_program = StudentEvaluated.all.includes(:program)
    @total_alumnos_program_rango = ScoreStudentStat.all.includes(:program)
  end  

  def mentor_alumnos_asignados
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_evaluated_analytics_panel_index_path}'>Alumnos asignados por mentor</a>".html_safe
    @mentors = Mentor.all.invitation_accepted.page(params[:page]).per(30)
    @asignados = User.students.invitation_accepted.where.not(coach_id:  nil).where("user_seen > 0.0").count
    @sinasignar = User.students.invitation_accepted.where(coach_id: nil).where("user_seen > 0.0").count
    @sin_actividad_sinasignar = User.students.invitation_accepted.where(coach_id: nil).where(user_seen: 0.0).count

    @enblanco = User.students.invitation_accepted.where(group_id: nil).count
    @zzzzz = User.students.invitation_accepted.where(user_seen: 0.0).count
    @activos = User.students.invitation_accepted.where("user_seen > 0.0").count
    @total = User.students.invitation_accepted.count
  end

  def students_evaluated_progress
    @job_id = params[:id]
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_evaluated_progress_analytics_panel_path(@job_id)}'>Calculando estadisticas de alumnos evaluados</a>".html_safe
  end

  def search
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{search_analytics_panel_index_path}'>Buscador</a>".html_safe
    if params[:query].present?
      @user = User.find(params[:query]) rescue nil
      unless @user.nil?
        @programs = @user.group.all_programs
        bienvenido_program = Program.where("name like ?", "%" + "¡Bienvenid" + "%").last
        unless bienvenido_program.nil? 
          @bienvenido = bienvenido_program.chapters.where("name like ?", "%" + "Diagnóstico" + "%").last
        else
          @bienvenido = nil
        end
      end
    else
      @user = "buscador"
    end    
  end

  def alumnos_estados
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{alumnos_estados_analytics_panel_index_path}'>Alumnos por estado (tutores)</a>".html_safe
    @mentors = Mentor.all.invitation_accepted.page(params[:page]).per(30)
    @states = State.all.order(:id)

    @ssc = StudentsStatesCoach.all
    @sinasignar = {}; @sinactividad_noasignados = {}; @total_alumnos_state = {};

    unless @ssc.first.nil?
      @states.each do |state|
        sin_asig = User.students.invitation_accepted.joins(:group).where("groups.state_id = ? and users.user_seen > 0 and users.coach_id is null", state.id).count
        @sinasignar.merge!(state.id => sin_asig)
        
        noacti_noasig = User.students.invitation_accepted.joins(:group).where("groups.state_id = ? and users.user_seen = 0 and users.coach_id is null", state.id).count   
        @sinactividad_noasignados.merge!(state.id => noacti_noasig)
        
        total = User.students.invitation_accepted.joins(:group).where("groups.state_id = ?", state.id).count  
        @total_alumnos_state.merge!(state.id => total)
      end  
    end
  end 

  def create_alumnos_estados
    @mentors = Mentor.all.invitation_accepted
    @states = State.all
    timestamp = Time.current.to_i

    redis = Redis.new
    redis.set("job_#{timestamp}", {
      total: @mentors.count,
      progress: 0
    }.to_json) 

    @mentors.each do |mentor|
      AnalyticsMentorStateJob.perform_async(mentor, @states, "job_#{timestamp}")
    end
    flash[:notice] = "Calculando Avances"
    redirect_to alumnos_estados_progress_analytics_panel_path(timestamp)  
  end

  def alumnos_estados_progress
    @job_id = params[:id]
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{alumnos_estados_progress_analytics_panel_path(@job_id)}'>Calculando estadisticas - Alumnos por estado (Mentores)</a>".html_safe
  end

  def seguimiento
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{seguimiento_analytics_panel_index_path}'>Seguimiento de EDC Digital</a>".html_safe
    @mentors = Mentor.all.invitation_accepted.page(params[:page]).per(50)
    if params[:date].present?
      @today = Date.parse(params[:date])
    else
      @today = Date.today # Today's date
    end
 
    @basics = []
    Program.basico.each do |program|
      @basics += program.template_refilables.pluck(:id)
    end 

    @medium = []
    Program.intermedio.each do |program|
      @medium += program.template_refilables.pluck(:id)
    end

    @advanced = []
    Program.avanzado.each do |program|
      @advanced += program.template_refilables.pluck(:id)
    end
    @days_from_this_week = (@today.at_beginning_of_week..@today.at_beginning_of_week + 4.days).map.to_a
    @total_tickets = Ticket.where(closed: true, category: 1).count
    @total_basics = tickets_type(@basics)
    @total_medium = tickets_type(@medium)
    @total_advanced = tickets_type(@advanced)
  end
    
  private
  def set_group
    @group = Group.find(params[:id])
  end

  def set_program
    @program = Program.find(params[:id])
  end

  def program_objects(program)
  	#program_groups = @groups.includes(:group_programs).wher(:group_programs => {program_id: program})
    program_groups = program.all_groups(current_user)
  	my_students = User.where(group_id: program_groups.pluck(:id), role: 0).where.not(invitation_accepted_at: nil)
  	actives = my_students.count
  	checked = my_students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program}).count
  	return [program_groups, actives, checked]
  end

  def tickets_type(ids)
    Ticket.where(element_id: ids, closed: true, category: 1).count 
  end  
end