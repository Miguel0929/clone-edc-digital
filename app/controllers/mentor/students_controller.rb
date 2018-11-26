class Mentor::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  helper_method :get_program_stat
  helper_method :get_program_active
  helper_method :chapter_have_questions?
  helper_method :new_refilable_answer
  include KeyQuestionsHelper
  include GroupHelper

  def index
    add_breadcrumb "<a class='active' href='#{mentor_students_path}'>Estudiantes</a>".html_safe

    #@users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
    #  .page(params[:page]).per(100)
    @groups = current_user.groups
    @universities = University.where(id: current_user.groups.pluck(:university_id) )
    couching_ids = current_user.trainees.pluck(:id)

    ids = current_user.groups.joins(:students).pluck('users.id') + couching_ids
  
    @users = User.students.where('users.id in (?)', ids).includes(:group)
    @users = @users.students_table.where('users.id in (?)', ids).search_query(params[:query]) if params[:query].present?


    if params[:status].present?
      case params[:status]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    if params[:group].present?
      @users = @users.where(group: params[:group])
    end

    if params[:university].present?
      @users = @users.joins(:group).where(groups: {university_id: params[:university]})
    end

    if params[:state].present?
      @users = @users.joins(:group).where(groups: {state_id: params[:state]})
    end

    if params[:tipo].present?
      @users = @users.joins(:group).where(groups: {category: params[:tipo]})
    end

    if params[:industria].present?
      @users = @users.where(industry_id: params[:industria])
    end
    
    if params[:answered].present?
      lower_a = params[:answered].to_i - ( params[:answered] == "10" ? 10 : 9.999)
      upper_a = params[:answered].to_i
    end
    if params[:answered].present? && !params[:program].present?
      @users = @users.where(user_progress: lower_a..upper_a)
    elsif params[:answered].present? && params[:program].present?
      @users = @users.joins(:program_stats).where(:program_stats => {program_id: params[:program], program_progress: lower_a..upper_a})
    end

    #ids = []
    if params[:visited].present?
      lower_s = params[:visited].to_i - ( params[:visited] == "10" ? 10 : 9.999)
      upper_s = params[:visited].to_i
    end
    if params[:visited].present? && !params[:program].present?
      @users = @users.where(user_seen: lower_s..upper_s)
    elsif params[:visited].present? && params[:program].present?
      @users = @users.joins(:program_stats).where(:program_stats => {program_id: params[:program], program_seen: lower_s..upper_s})
    end
    @users=@users.page(params[:page]).per(10)

  end


  def show
    @user = User.find(params[:id])
    unless @user.my_student?(current_user) then redirect_to mentor_students_path, notice: "Este alumno no es parte de tus asesorado" end

    add_breadcrumb "Estudiantes", :mentor_students_path
    add_breadcrumb "<a class='active' href='#{mentor_student_path(@user)}'>#{@user.email}</a>".html_safe

    @comments = Comment.select(
      'comments.*, users.first_name, users.last_name, questions.question_text, programs.name as program_name, chapter_contents.id as chapter_content_id, answers.id as answer_id'
    )
    .joins(:user, answer: [:question])
    .joins("INNER JOIN chapter_contents on chapter_contents.coursable_id = questions.id and coursable_type = 'Question'")
    .joins("INNER JOIN chapters on chapter_contents.chapter_id = chapters.id")
    .joins("INNER JOIN programs on programs.id = chapters.program_id")
    .where("users.id = ?", @user.id)
    .order(created_at: :desc)

    aux = []
                                    
    group_programs = @user.group.programs.pluck(:id) rescue []
    @user.group.nil?  || @user.group.learning_path.nil? ? fisica_programs = [] : fisica_programs = @user.group.learning_path.learning_path_contents.where(content_type: "Program").pluck(:content_id)
    @user.group.nil? || @user.group.learning_path2.nil?  ? moral_programs = [] : moral_programs = @user.group.learning_path2.learning_path_contents.where(content_type: "Program").pluck(:content_id)

    @complementarios = group_programs - (fisica_programs + moral_programs)
                             
    @programs = sort_programs(@user.group, @user.group.all_programs) rescue [] # @user.group.all_programs
                                 
    @delireverables = @user.group.all_delireverables rescue []

    @refilables = @user.group.all_refilables rescue []                

    @quizzes = @user.group.all_quizzes rescue []

    @key_questions = key_questions_hash

    @key_programs = @key_questions.map{|kqs| kqs[:program]}.uniq 
  end

  def exports
    #@users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
    @users = User.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
    respond_to do |format|
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="Lista de alumnos.xlsx"'}
    end
  end

  def analytics_quiz
    @quiz = Quiz.find(params[:quiz_id])
    @user = User.find(params[:id])
    unless @user.my_student?(current_user) then redirect_to mentor_students_path, notice: "Este alumno no es parte de tus asesorados." end
    clean_repeated_answers(@quiz, @user)
    add_breadcrumb "Estudiantes", :mentor_students_path
    add_breadcrumb "<a href='#{mentor_student_path(@user)}'>#{@user.email}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{analytics_quiz_mentor_student_path(@user, quiz_id: @quiz)}'>Detalles de la evaluación</a>".html_safe
  end  

  def get_program_stat(user, program)
    ProgramStat.where(user_id: user.id, program_id: program.id).last
  end

  def get_program_active(user, program)
    ProgramActive.where(user_id: user.id, program_id: program.id).first
  end

  def update
    respond_to do |format|
      @user = User.find(params[:id])
      if @user.update(student_params)
        format.json { render json: @user, status: :ok }
      else
        format.json {render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def chapter_have_questions?(program)
    with_questions, no_questions = [], []
    program.chapters.each do |chapter|
      if chapter.all_questions.count > 0
        with_questions << chapter
      else
        no_questions << chapter
      end
    end
    return with_questions, no_questions
  end

  def summary
    @user = User.find(params[:id])
    unless @user.my_student?(current_user) then redirect_to mentor_students_path, notice: "Este alumno no es parte de tus grupos" end
    add_breadcrumb "<a href='#{students_users_path}'>Estudiantes</a>".html_safe
    add_breadcrumb "<a href='#{mentor_student_path(@user)}'>#{@user.email}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{summary_mentor_student_path(@user)}'>Vista rápida: #{@user.email}</a>".html_safe
    quizzes_results = @user.answered_quizzes
    @quizzes_average = quizzes_results[0]
    @answered_quizzes = quizzes_results[1]
    @total_quizzes = @user.total_quizzes
    @delireverables = @user.group.all_delireverables.count rescue 0
    @refilables = @user.group.all_refilables.count rescue 0
    @complete_delireverables = DelireverableUser.where(user: @user).count
    @complete_refilables = Refilable.where(user: @user).count
    @self_archives = @user.attachments.count
    @shared_archives = @user.shared_attachments.count
    @sent_chats = Mailboxer::Message.where(sender_id: @user).count
    @mentor_messages = MentorHelp.where(sender: @user.id).count
    if @total_quizzes == 0
      @result_exams = 0
    else
      @result_exams = @answered_quizzes.to_f / @total_quizzes.to_f * 100 
    end
    if @delireverables == 0
      @result_delireverables = 0
    else    
      @result_delireverables = @complete_delireverables.to_f / @delireverables.to_f * 100
    end
    if  @refilables == 0
      @result_refilables = 0
    else
      @result_refilables = @complete_refilables.to_f / @refilables.to_f * 100 
    end
  end

  def template_refilables

    add_breadcrumb "<a href='#{mentor_students_path}'>Estudiantes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{template_refilables_mentor_students_path}'>Plantillas de estudiantes</a>".html_safe
    
    @groups = current_user.groups
    @universities = University.where(id: current_user.groups.pluck(:university_id))
    @template_refilables = TemplateRefilable.all
    couching_ids = current_user.trainees.pluck(:id)
    ids = current_user.groups.joins(:students).pluck('users.id') + couching_ids

    @users = User.students.where('users.id in (?)', ids).includes(:group)
    @users = @users.students_table.where('users.id in (?)', ids).search_query(params[:query]).includes(:group) if params[:query].present?
    if params[:status].present?
      case params[:status]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    if params[:group].present?
      @users = @users.where(group: params[:group])
    end

    if params[:university].present?
      @users = @users.joins(:group).where(groups: {university_id: params[:university]})
    end

    if params[:state].present?
      @users = @users.joins(:group).where(groups: {state_id: params[:state]})
    end

    if params[:tipo].present?
      @users = @users.joins(:group).where(groups: {category: params[:tipo]})
    end

    if params[:industria].present?
      @users = @users.where(industry_id: params[:industria])
    end

    if params[:template_refilable].present?
      @users = @users.joins(:refilables).where(refilables: {template_refilable_id: params[:template_refilable]})
    end
    
    @users=@users.page(params[:page]).per(20)
  end
  
  def quizzes
    add_breadcrumb "<a href='#{mentor_students_path}'>Estudiantes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{quizzes_mentor_students_path}'>Evaluaciones de estudiantes</a>".html_safe
    
    @groups = current_user.groups
    @universities = University.where(id: current_user.groups.pluck(:university_id) )
    couching_ids = current_user.trainees.pluck(:id)
    ids = current_user.groups.joins(:students).pluck('users.id') + couching_ids
    @users = User.students.where('users.id in (?)', ids)
    @users = @users.students_table.where('users.id in (?)', ids).search_query(params[:query]) if params[:query].present?

    if params[:status].present?
      case params[:status]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    if params[:group].present?
      @users = @users.where(group: params[:group])
    end

    if params[:university].present?
      @users = @users.joins(:group).where(groups: {university_id: params[:university]})
    end

    if params[:state].present?
      @users = @users.joins(:group).where(groups: {state_id: params[:state]})
    end

    if params[:tipo].present?
      @users = @users.joins(:group).where(groups: {category: params[:tipo]})
    end

    if params[:industria].present?
      @users = @users.where(industry_id: params[:industria])
    end

    if params[:quiz].present?
      quiz = Quiz.find(params[:quiz])
      ids = []
      @users.each do |user|
        if quiz.answered?(user)
          ids << user.id
        end  
      end
      @users = User.where(id: ids)  
    end
        
    @users=@users.page(params[:page]).per(20)
  end  

  private
  def percentage_condition(percentage, count)
    case count
      when 10
        percentage >= 0 && percentage <=10
      when 20
        percentage >= 11 && percentage <=20
      when 30
        percentage >= 21 && percentage <=30
      when 4
        percentage >= 31 && percentage <=40
      when 50
        percentage >= 41 && percentage <=50
      when 60
        percentage >= 51 && percentage <=60
      when 70
        percentage >= 61 && percentage <=70
      when 80
        percentage >= 71 && percentage <=80
      when 90
        percentage >= 81 && percentage <=90
      when 100
        percentage >= 91 && percentage <=100
    end
  end

  def student_params
    params.require('user').permit(:evaluation_status)
  end

  def new_refilable_answer(refilables, refilable)
    if refilables.count >= 2
      remaining = refilables.where( id: (refilables.pluck(:id) - [refilable.id]) )
      if remaining.map{ |r| r.points }.detect{ |x| x != nil } != nil && refilable.points.nil?
        return true 
      else
        return false
      end
    else
      return false
    end
  end
end
