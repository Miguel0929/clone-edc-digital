class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_learning, if: :permiso_avance, only: [:show]
  add_breadcrumb "EDCDIGITAL", :root_path

  helper_method :last_moved_program
  helper_method :last_visited_content

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_programs_path}'>Programas</a>".html_safe
    #@programs = current_user.group.programs.order(position: :asc) rescue []
    
    ids=[]
    if current_user.student?
      unless current_user.group.nil?
        ids_comp=[] 
        @activo = ['active', '','']
        aux = current_user.group.programs.where.not(content_type: 0).map{|p|p.id}
        aux.each do |id|
          if !ProgramActive.where(user: current_user, program_id: id).first.nil? && ProgramActive.where(user: current_user, program_id: id).first.status
            ids_comp.push(id)
          end
        end  
        @programs = current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position)
        c=0
        @programs.each do |p|
          c+=1
          if c==1 || current_user.percentage_questions_answered_for(p.anterior(current_user.group))>80
            ids.push(p.content_id)
          else
            break
          end
        end
        @programs=Program.where(id: ids_comp.concat(ids))
      end
    elsif current_user.mentor?
      current_user.groups.each do |g|
        g.programs.each do |p|
          unless ids.include?(p.id)          
            ids.push(p.id)         
          end
        end  
      end
      @programs = Program.where(id: ids).order(:position)
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
  def redirect_to_learning
    redirect_to dashboard_learning_path_path, notice: "Aun no puedes acceder a este contenido." 
  end  
  def permiso_avance
    @program = Program.find(params[:id])
    active=ProgramActive.where(user: current_user, program: @program).first
    is_active=true
    programas = current_user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position)
    if active.nil? then is_active = false else is_active = active.status end  
    if is_active || current_user.mentor? 
      return false
    end  
    if @program != programas.first.model  
      anterior=Program.new
      programas.each do |p|
        if p.model==@program
          break
        else
          anterior=p.model
        end
      end
      programas.each do |p|
        if (p.model == anterior && current_user.percentage_answered_for(anterior) == 100)
          return false      
        elsif (current_user.percentage_answered_for(p.model) < 100 && p.model != anterior) 
          return true
        end  
      end
    else
      return false
    end      
  end  

end
