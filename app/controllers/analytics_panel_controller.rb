class AnalyticsPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor_or_profesor
  before_action :set_group, only: [:group]
  before_action :set_program, only: [:group_program]
  add_breadcrumb "EDCDIGITAL", :root_path
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
      bienvenido_program = Program.where("name like ?", "%" + "¡Bienvenid" + "%").last
      unless bienvenido_program.nil? 
        @bienvenido = bienvenido_program.chapters.where("name like ?", "%" + "Diagnóstico" + "%").last
      else
        @bienvenido = nil
      end  
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

  def students_evaluated
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_evaluated_analytics_panel_index_path}'>Alumnos evaluados</a>".html_safe
    
    @groups = Group.all
    @programs = Program.all.order(:id).page(params[:page]).per(15)
    @total_alumnos_program = []
    @total_100_90 = []; @total_89_80 = []; @total_79_60 = []; @total_59_0 = [] 
    @programs.each do |program|
      alumnos = 0; evaluados = 0; evaluados100_90 = 0; evaluados89_80 = 0; evaluados79_60 = 0; evaluados59_0 = 0; estudiantes = [];  
      total_puntos_program = program.total_points
      @groups.each do |group|
        programas_grupo = group.all_programs 
        if programas_grupo.include?(program)
          alumnos += group.active_students.count
          evaluados += group.students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id}).count
=begin   
          estudiantes = group.students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id})
          estudiantes.each do |student|
            obtenidos = program.points_earned(student)
            promedio = user_promedio_refilable(obtenidos, total_puntos_program)
            if promedio <= 100 && promedio >= 90
              evaluados100_90 += 1
            elsif promedio <= 89 && promedio >= 80
              evaluados89_80 += 1
            elsif promedio <= 79 && promedio >= 60
              evaluados79_60 += 1
            elsif promedio <= 59 && promedio >= 0  
              evaluados59_0 += 1
            end  
          end
=end                     
        end
      end
      @total_alumnos_program << {program_id: program.id, program_name: program.name ,alumnos: alumnos, evaluados: evaluados, no_evaluados: alumnos - evaluados}
=begin
      @total_100_90 << {program_id: program.id, alumnos: evaluados100_90} 
      @total_89_80 << {program_id: program.id, alumnos: evaluados89_80}
      @total_79_60 << {program_id: program.id, alumnos: evaluados79_60}
      @total_59_0 << {program_id: program.id, alumnos: evaluados59_0}
=end      
    end  
  end

  def mentor_alumnos_asignados
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_evaluated_analytics_panel_index_path}'>Alumnos asignados por mentor</a>".html_safe
    @mentors = Mentor.all.page(params[:page]).per(50)
    @enblanco = User.students.where(group_id: nil).count
    @total = User.students.count
  end 

  private
  def set_group
    @group = Group.find(params[:id])
  end

  def set_program
    @program = Program.find(params[:id])
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