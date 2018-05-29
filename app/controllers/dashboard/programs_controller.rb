class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:show]
  before_action :redirect_to_support, if: :student_have_group?
  before_action :redirect_to_learning, if: :permiso_avance, only: [:show]
  add_breadcrumb "EDCDIGITAL", :root_path

  helper_method :last_moved_program
  helper_method :last_visited_content
  helper_method :evaluation_checked?
  include ActiveElementsHelper

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_programs_path}'>Programas</a>".html_safe
    
    if current_user.student?
      @activo = ['active', '','']
      if current_user.group.nil?
        @programs = []
      else
        @programs = get_active_programs(current_user)
      end
    elsif current_user.mentor? || current_user.profesor?
      @programs = current_user.groups.map{|g| g.all_programs}.flatten.uniq
    else
      @programs = Program.all
    end

 
    
    if params[:tipo]=="elearning"
      userprograms = current_user.group.group_programs.joins(:program).where(programs: { tipo: "0"}).order(:position).pluck(:id)
      @programs =  Program.where(id: userprograms).order(:position)
      @activo = ['', '','active']


    elsif params[:tipo]=="construccion"
      userprograms = current_user.group.group_programs.joins(:program).where(programs: { tipo: "1"}).order(:position)
      @programs = Program.where(id: userprograms).order(:position)
      @activo = ['', 'active','']
    end

    if params[:level]=="basico"
      @programs = current_user.group.group_programs.joins(:program).where(programs: { level: "0"}).order(:position)
    elsif params[:level]=="intermedio"
      @programs = current_user.group.group_programs.joins(:program).where(programs: { level: "1"}).order(:position)
    elsif params[:level]=="avanzado"  
      @programs = current_user.group.group_programs.joins(:program).where(programs: { level: "2"}).order(:position)
    end

    if params[:orden]=="tipo"
      userprograms = current_user.group.programs.order(:tipo)
      @programs = userprograms.map { |p| p.group_programs.find_by(group_id: current_user.group.id) }
    elsif params[:orden]=="ruta"
      @programs = current_user.group.group_programs.order(:position)
    elsif params[:orden]=="abc"
      userprograms = current_user.group.programs.order(name: :asc)
      @programs = userprograms.map { |p| p.group_programs.find_by(group_id: current_user.group.id) }
    end  
  end

  def show
    rank= Rating.where(ratingable_type: "Program", ratingable_id: @program.id, user_id: current_user.id).first
    if rank.nil?
      @rank=0
    else
      @rank=rank.rank
    end 

    @tour_trigger = current_user.tour_trigger
    clean_repeated_refilables(@program, current_user)
    @answered_quizzes = @program.percentage_answered_quizzes(current_user)
    @answered_templates = @program.percentage_answered_template_refillables(current_user)

    add_breadcrumb "Mi ruta", :dashboard_learning_path_path
    add_breadcrumb "<a class='active' href='#{dashboard_program_path @program}'>#{@program.name}</a>".html_safe
    respond_to do |format|
      format.html
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="mis_respuestas_#{@program.name}.xlsx"'}
    end
  end

  def resume
    @program = Program.find(params[:id])
    add_breadcrumb "programas", :dashboard_programs_path
    add_breadcrumb @program.name, dashboard_program_path(@program)
    add_breadcrumb "<a class='active' href='#{resume_dashboard_program_path @program}'>Rúbrica de evaluación</a>".html_safe
    @user = current_user

  end

  def evaluation_checked?(user, evaluation)
    UserEvaluation.where(user_id: user, evaluation_id: evaluation).exists?
  end

  private
  def last_moved_program(program)
     last_moved_content = program.get_last_move(current_user)
    if !last_moved_content.nil?
      last_move = last_moved_content.chapter_content_id
      last_time = last_moved_content.updated_at
      last_content = ChapterContent.find(last_moved_content.chapter_content_id)
      
      if last_content.coursable_type == "Lesson"
        last_text = last_content.model.identifier
      elsif last_content.coursable_type == "Chapter"
        last_text = "contenedor #{last_content.id}"
      else
        last_text = last_content.model.question_text
      end
    end
    return last_move, last_time, last_content, last_text, last_moved_content
  end

  def last_visited_content(program, stats)
    if stats != nil
      last = ( !stats.last_content.nil? ? stats.last_content : nil)
      return last
    else
      return nil
    end
  end

  def set_program
    @program=Program.find(params[:id])
  end

  def permiso_avance
    permiso_programs(@program, current_user)
  end  

end
