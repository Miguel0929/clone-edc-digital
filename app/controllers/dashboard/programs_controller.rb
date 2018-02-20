class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:show]
  before_action :redirect_to_support, if: :student_have_group?
  before_action :redirect_to_learning, if: :permiso_avance, only: [:show]
  add_breadcrumb "EDCDIGITAL", :root_path

  helper_method :last_moved_program
  helper_method :last_visited_content

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_programs_path}'>Programas</a>".html_safe
    
    if current_user.student?
      @activo = ['active', '','']
      unless current_user.group.nil?
        ids_comp = []; ids_fisica = []; ids_moral = [] 

        current_user.group.learning_path.nil? ? program_fisico = [] : program_fisico = current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position)

        current_user.group.learning_path2.nil? ? program_moral = [] : program_moral = current_user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position)
    

        program_group = current_user.group.programs.map{|p|p.id}
        if program_fisico == [] && program_moral == []
          p_f = []; p_m = []; 
        elsif program_moral == [] && program_fisico != []
          p_f = program_fisico.pluck(:content_id); p_m = []; 
        elsif program_fisico == [] && program_moral != []
          p_f = []; p_m = program_moral.pluck(:content_id);
        else
           p_f = program_fisico.pluck(:content_id); p_m = program_moral.pluck(:content_id);  
        end  
        complementarios = program_group - (p_f + p_m)

        complementarios.each do |id|
          if !ProgramActive.where(user: current_user, program_id: id).first.nil? && ProgramActive.where(user: current_user, program_id: id).first.status
            ids_comp << id
          end
        end
  
        @programs=Program.where(id: ids_comp+p_f+p_m)
      end
    elsif current_user.mentor? || current_user.profesor?|| current_user.admin?
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

    add_breadcrumb "Programas", :dashboard_programs_path
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
      elsif last_content.coursable_type == "Quiz"
        last_text = last_content.model.name
      elsif last_content.coursable_type == "TemplateRefilable"
        last_text = last_content.model.name
      elsif last_content.coursable_type == "DelireverablePackage"  
        last_text = last_content.model.name
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
