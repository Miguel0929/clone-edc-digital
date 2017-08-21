class Dashboard::AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  before_action :validate_coursable_type
  before_action :build_question
  after_action :update_program_stats, only: [:create, :update]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path

  def router
    answer = build_answer

    if answer.new_record?
      redirect_to new_dashboard_chapter_content_answer_path(@chapter_content)
    else
      redirect_to dashboard_chapter_content_answer_path(@chapter_content, answer)
    end
  end

  def show
    @tour_trigger = current_user.tour_trigger
    @answer = Answer.find(params[:id])
    #@comments = @question.comments.where(owner: current_user).order(created_at: :asc)
    ahoy.track "Viewed content", chapter_content_id: @chapter_content.id

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe
  end

  def new
    @tour_trigger = current_user.tour_trigger
    @answer = build_answer
    #@comments = @question.comments.where(owner: current_user).order(created_at: :asc)
    ahoy.track "Viewed content", chapter_content_id: @chapter_content.id

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe

  end

  def create
    @answer = @question.answers.new(answer_params)

    @answer.user = current_user

    @answer.answer_text = sanitize_answer if @question.checkbox?

    @answer.save

    redirect_to_next_content 
  end

  def edit
    @answer = Answer.find(params[:id])

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe
  end

  def update
    @answer = Answer.find(params[:id])

    @answer.answer_text = sanitize_answer if @question.checkbox?

    @answer.assign_attributes(answer_params)

    @answer.save

    redirect_to_next_content
  end

  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end

  def validate_coursable_type
    redirect_to root_url unless @chapter_content.coursable_type == 'Question'
  end

  def build_question
    @question = @chapter_content.model
  end

  def build_answer
    @question.answers.find_by(user: current_user, question: @question) || @question.answers.new(user: current_user)
  end

  def answer_params
    params.require(:answer).permit(:user_id, :question_id, :answer_text)
  end

  def sanitize_answer
    params[:answer][:answer_text].join('\n') if params[:answer][:answer_text].present?
  end

  def redirect_to_next_content
    mensaje= "Cambios guardados con éxito"
    program=@chapter_content.chapter.program
    if current_user.percentage_questions_answered_for(program)>80 && current_user.percentage_questions_answered_for(program)<100
      if current_user.program_notifications.where(program: program).more80.first.nil?
        current_user.program_notifications.create(program: program, notification_type: 'more80')
        if current_user.panel_notifications.more80_student.first.nil? || current_user.panel_notifications.more80_student.first.status
          Programs.more80_student(program, current_user, dashboard_program_url(program))
        end
        #soporte
        soporte=User.new(email: "soporte@edc-digital.com")
        Programs.more80_mentor(program,soporte,current_user,user_url(current_user))
        if program.ruta?
          flash[:more80]="Haz completado el 80% del curso, pronto desbloquearas el siguiente contenido!"
        else
          flash[:more80]="Haz completado el 80% del curso!"
        end    
        #mentores
        ProgramMore80NotificationJob.perform_async(program,current_user,mentor_student_url(current_user))
      end
      if program.ruta?
        mensaje = mensaje + ", haz completado el #{current_user.percentage_questions_answered_for(program)}\% del programa, ya mero entras al siguiente curso."
      else
        mensaje = mensaje + ", haz completado el #{current_user.percentage_questions_answered_for(program)}\% del programa."
      end  
    elsif current_user.percentage_questions_answered_for(program)==100
      if current_user.program_notifications.where(program: program).complete.first.nil?
        current_user.program_notifications.create(program: program, notification_type: 'complete')
        if current_user.panel_notifications.complete_student.first.nil? || current_user.panel_notifications.complete_student.first.status
          Programs.complete_student(program, current_user, dashboard_program_url(program))
        end
        #soporte
        soporte=User.new(email: "soporte@edc-digital.com")
        Programs.complete_mentor(program,soporte,current_user,user_url(current_user))
        flash[:complete]="Haz completado el curso!"
        #mentores
        ProgramCompleteNotificationJob.perform_async(program,current_user,mentor_student_url(current_user))
      end
      if program.ruta?  
        mensaje = mensaje + ", haz completado el 100% del curso, se ha desbloqueado un nuevo contenido."
      else
        mensaje = mensaje + ", haz completado el 100% del curso."
      end      
    end   
    if @chapter_content.lower_item
      redirect_to dashboard_chapter_content_path(@chapter_content.lower_item), notice: mensaje
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
    progress = @current_user.percentage_questions_answered_for(program)
    seen = @current_user.percentage_content_visited_for(program)

    if program_stat.nil?
      new_stat = ProgramStat.create(user_id: @current_user.id, program_id: program.id, program_progress: progress, program_seen: seen)
    else
      program_stat.update(program_progress: progress, program_seen: seen)
    end
  end
end
