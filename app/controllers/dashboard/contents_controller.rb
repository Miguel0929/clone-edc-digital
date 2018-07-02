class Dashboard::ContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  before_action :redirect_to_support, if: :student_have_group?
  before_action :is_answered?, only: [:new]
  after_action :update_program_stats, only: [:create, :update]
  after_action only: [:create, :update] do |c|
    c.send(:diagnostic_test_process, params[:chapter_content_id])
  end
  before_action :redirect_to_learning, if: :permiso_avance, only: [:show, :new, :edit]
  
  add_breadcrumb "EDCDIGITAL", :root_path

  def router
    contestadas = current_user.answers_for(@chapter_content.model).count
    content = @chapter_content.model.questions_count
    contenedor = @chapter_content.model
    if contestadas == content    
      redirect_to dashboard_chapter_content_content_path(@chapter_content, contenedor)
    else
      redirect_to new_dashboard_chapter_content_content_path(@chapter_content)
    end
  end

  def new

    @content=@chapter_content.model
    @answers = []
    @content.questions.each do |question|
      @answers << Answer.new(question_id: question.id, user_id: current_user.id)
    end
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>Contenedor: #{@chapter_content.model.name}</a>".html_safe
  end

  def show
    @content=@chapter_content.model
    @answers = Answer.where(question_id: @content.questions.pluck(:id), user_id: current_user.id)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>Contenedor: #{@chapter_content.model.name}</a>".html_safe
  end

  def edit 
    @content=@chapter_content.model
    @answers = Answer.where(question_id: @content.questions.pluck(:id), user_id: current_user.id)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>Editar Preguntas</a>".html_safe
  end

  def create
    #render :json => {1=>params[:answers]}  
    chapter = @chapter_content.model
    
    if params[:answers].map{ |a| a[1][:answer_text]}.include?(nil)
      redirect_to :back, alert: "Debes contestar todas las preguntas"
    else
      if current_user.answers_for(chapter).count > 0
        @ans = Answer.where(question_id: chapter.questions.map{ |q| q.id }, user_id: current_user.id)
        @ans.delete_all
      end 
      params[:answers].each_with_index do |answer, index|
        answer_text = answer[1][:answer_text]
          if answer_text.class == Array
            resp = Answer.new(answer_params(answer))
            resp.answer_text = answer_text.join('\n')
            resp.save
          else
            resp = Answer.new(answer_params(answer))
            resp.save
          end
      end
      redirect_to_next_content 
    end  
  end

  def update
    chapter = @chapter_content.model

    if params[:answers].map{ |a| a[1][:answer_text]}.include?("")
      redirect_to :back, alert: "Debes contestar todas las preguntas"
    else
      params[:answers].each_with_index do |answer, index|
        answer_text = answer[1][:answer_text]
        resp = Answer.where(question_id: answer[1][:question_id], user_id: current_user.id).first
        if resp.nil?
          resp = Answer.new(answer_params(answer))
        end
        if answer_text.class == Array
          resp.answer_text = answer_text.join('\n')
        else
          resp.answer_text = answer_text 
        end
        resp.save
      end
      program = @chapter_content.chapter.program
      chap = @chapter_content.chapter
      UpdateQuestionNotificationJob.perform_async(@chapter_content, current_user, mentor_evaluation_url(chap, user_id: current_user.id, program_id: program.id))
      redirect_to_next_content 
    end   
  end 


  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end

  def answer_params(custom_params)
    ActionController::Parameters.new(custom_params[1]).permit(:user_id, :question_id, :answer_text)
  end

  def is_answered?
    content = @chapter_content.model
    questions = content.questions.count
    answers = Answer.where(question_id: content.questions.pluck(:id), user_id: current_user.id).count
    contenedor = @chapter_content.model
    if questions == answers && questions > 0
      redirect_to dashboard_chapter_content_content_path(@chapter_content, contenedor)
    end  
  end  
  
  def redirect_to_next_content
    mensaje= "Cambios guardados con éxito"  
      program=@chapter_content.chapter.program

    if current_user.percentage_answered_for(program) > 95 && current_user.percentage_answered_for(program) < 100
      if current_user.program_notifications.where(program: program).more95.first.nil?
        current_user.program_notifications.create(program: program, notification_type: 'more95')
        if current_user.panel_notifications.more95_student.first.nil? || current_user.panel_notifications.more95_student.first.status
          Programs.more95_student(program, current_user, dashboard_program_url(program))
        end
        #soporte
        #soporte=User.new(email: "soporte@edc-digital.com")
        #Programs.more95_mentor(program,soporte,current_user,user_url(current_user))
        flash[:more95]="Has completado el 95% del curso."  
        #mentores
        #ProgramMore95NotificationJob.perform_async(program,current_user,mentor_student_url(current_user))
      end
      mensaje = mensaje + ", has completado el #{current_user.percentage_answered_for(program)}\% del programa." 
    elsif current_user.percentage_answered_for(program)==100
      if current_user.program_notifications.where(program: program).complete.first.nil?
        current_user.program_notifications.create(program: program, notification_type: 'complete')
        #Se pidió eliminar el envío del correo (Valeria) de notificación cuando se acaba un programa
        #if (current_user.panel_notifications.complete_student.first.nil? || current_user.panel_notifications.complete_student.first.status) && !program.name.include?("¡Bienvenido")
        #  Programs.complete_student(program, current_user, dashboard_program_url(program))
        #end
        #soporte
        if !program.name.include?("¡Bienvenido")
          soporte=User.new(email: "soporte2@edc-digital.com")
          Programs.complete_mentor(program,soporte,current_user,user_url(current_user))
        end
        flash[:complete]="¡Has completado el curso!"
        #mentores
        if (program.id == 23 || program.id == 24)
          ProgramCompleteNotificationJob.perform_async(program,current_user,mentor_student_url(current_user))
        end
      end

      mensaje = mensaje + ", has completado el 100% del curso."    
    end   
    if @chapter_content.next_content
      redirect_to dashboard_chapter_content_path(@chapter_content.next_content), notice: mensaje
    elsif program.next_chapter(@chapter_content.chapter) && program.next_chapter(@chapter_content.chapter).chapter_contents.first
      redirect_to dashboard_chapter_content_path(program.next_chapter(@chapter_content.chapter).chapter_contents.first), notice: mensaje
    else
      redirect_to dashboard_program_path(program), notice: mensaje
    end
  end

  def update_program_stats
    #program = Program.joins(:chapters => :chapter_contents).where(chapter_contents: {id: @chapter_content.id}).last
    program = @chapter_content.chapter.program
    program_stat = ProgramStat.where(user_id: @current_user.id, program_id: program.id).last
    progress = @current_user.percentage_answered_for(program)
    seen = @current_user.percentage_content_visited_for(program)

    if program_stat.nil?
      new_stat = ProgramStat.create(user_id: @current_user.id, program_id: program.id, program_progress: progress, program_seen: seen)
    else
      program_stat.update(program_progress: progress, program_seen: seen)
    end
  end

  def diagnostic_test_process(ch_c_id)
    content = ChapterContent.find(ch_c_id)
    program = content.chapter.program
    if program.name.include?("¡Bienvenido!")
      d_chapter = content.chapter
      if d_chapter.name.include?("Diagnóstico")
        q_ids = d_chapter.questions.pluck(:id)
        q_answers = Answer.where(user_id: current_user, question_id: q_ids)
        first_time = UserEvaluation.where(evaluation_id: d_chapter.evaluations.pluck(:id), user_id: current_user).empty?
        if (q_ids.sort - q_answers.pluck(:question_id).sort).empty?
          DiagnosticTestJob.perform_async(q_answers, d_chapter, current_user, first_time)
        end
      end
    end
  end

  def permiso_avance
    permiso_programs(@chapter_content.chapter.program, current_user) 
  end
end
