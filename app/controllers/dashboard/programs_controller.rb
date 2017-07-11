class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_programs_path}'>Programas</a>".html_safe
    #@programs = current_user.group.programs.order(position: :asc) rescue []
    
    $redis.del "user_programs_#{current_user.id}" if params[:borrar_cache].present?
    ids=[]
    if current_user.student?
      unless current_user.group.nil? 
        programs = $redis.get("user_programs_#{current_user.id}")
        if programs.nil?
          programs = current_user.group.programs.to_json
          $redis.set("user_programs_#{current_user.id}", programs)
          $redis.expire("user_programs_#{current_user.id}", 60.minutes.to_i)
        end
        @programs = JSON.load programs
      end  
    elsif current_user.mentor?
      current_user.groups.each do |g|
        g.programs.each do |p|
          unless ids.include?(p.id)          
            ids.push(p.id)         
          end
        end  
      end
      programs = $redis.get("user_programs_#{current_user.id}")
      if programs.nil
        programs = Program.where(id: ids).to_json
        $redis.set("user_programs_#{current_user.id}", programs)
        $redis.expire("user_programs_#{current_user.id}", 60.minutes.to_i)
      end
      @programs = JSON.load programs
    end  
    
    if params[:tipo]=="elearning"
      @programs=@programs.where(tipo: 0)
    elsif params[:tipo]=="construccion"
      @programs=@programs.where(tipo: 1)
    end

    if params[:level]=="basico"
      @programs=@programs.where(level: 0)
    elsif params[:level]=="intermedio"
      @programs=@programs.where(level: 1)
    elsif params[:level]=="avanzado"  
      @programs=@programs.where(level: 2)
    end

    if params[:orden]=="tipo"
      @programs=@programs.order(:tipo)
    elsif params[:orden]=="ruta"
      @programs=@programs.order("group_programs.position")  
    elsif params[:orden]=="abc"
      @programs=@programs.order(name: :asc) 
    end  

  end

  def show
    @program = Program.find(params[:id])

    rank= Rating.where(ratingable_type: "Program", ratingable_id: @program.id, user_id: current_user.id).first
    if rank.nil?
      @rank=0
    else
      @rank=rank.rank
    end 

    @last_moved_content = @program.get_last_move(@program, current_user)
    if !@last_moved_content.nil?
      @last_move = @last_moved_content.chapter_content_id
      @last_time = @last_moved_content.updated_at
      last_content = ChapterContent.find(@last_moved_content.chapter_content_id)
      
      if last_content.coursable_type == "Lesson"
        @last_text = last_content.model.identifier
      else
        @last_text = last_content.model.question_text
      end
    end

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

end
