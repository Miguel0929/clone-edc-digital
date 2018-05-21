class Profesor::StudentsController < ApplicationController
	before_action :authenticate_user!
  before_action :require_profesor

  add_breadcrumb "EDC DIGITAL", :root_path
  helper_method :chapter_have_questions?
  helper_method :get_program_stat
  helper_method :get_program_active
  include KeyQuestionsHelper

  def index
    add_breadcrumb "<a class='active' href='#{profesor_students_path}'>Estudiantes</a>".html_safe

    @groups = current_user.groups
    @universities = University.where(id: current_user.groups.pluck(:university_id) )
    @users = User.students.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
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

    ids=[]
    if params[:answered].present? && params[:program].length==0
      @users.each do |user|
        percentage = user.answered_questions_percentage rescue 0
        if params[:answered].to_i >= percentage && params[:answered].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    elsif params[:answered].present? && params[:program].length > 0
      @users.each do |user|
        percentage = user.percentage_questions_answered_for(Program.find(params[:program])) rescue 0
        if params[:answered].to_i >= percentage && params[:answered].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    end
    ids=[]
    if params[:visited].present? && params[:program].length==0
      @users.each do |user|
        percentage = user.content_visited_percentage rescue 0
        if params[:visited].to_i >= percentage && params[:visited].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    elsif params[:visited].present? && params[:program].length > 0
      @users.each do |user|
        percentage = user.percentage_content_visited_for(Program.find(params[:program])) rescue 0
        if params[:visited].to_i >= percentage && params[:visited].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    end
    @users=@users.page(params[:page]).per(10)
    #@users = @users.where(group: params[:group]) if params[:group].present?
    @users = @users.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id')).search_query(params[:query]) if params[:query].present?
  end

  def show
    @user = User.find(params[:id])
    unless @user.my_student?(current_user) then redirect_to profesor_students_path, notice: "Este alumno no es parte de tus grupos" end

    add_breadcrumb "Estudiantes", :profesor_students_path
    add_breadcrumb "<a class='active' href='#{profesor_student_path(@user)}'>#{@user.email}</a>".html_safe

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
                             
    @programs=@user.group.all_programs rescue []
                                 
    @delireverables=@user.group.all_delireverables rescue []

    @refilables=@user.group.all_refilables rescue []                            

    @quizzes=@user.group.all_quizzes rescue []

    @key_questions = key_questions_hash

    @key_programs = @key_questions.map{|kqs| kqs[:program]}.uniq 
  end

  def summary
    @user = User.find(params[:id])
    unless @user.my_student?(current_user) then redirect_to profesor_students_path, notice: "Este alumno no es parte de tus grupos" end
    add_breadcrumb "<a href='#{profesor_students_path}'>Estudiantes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{summary_profesor_student_path(@user)}'>Vista rápida: #{@user.email}</a>".html_safe
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

  def analytics_quiz
    @quiz = Quiz.find(params[:quiz_id])
    @user = User.find(params[:id])
    unless @user.my_student?(current_user) then redirect_to profesor_students_path, notice: "Este alumno no es parte de tus grupos" end
    clean_repeated_answers(@quiz, @user)
    add_breadcrumb "Estudiantes", :profesor_students_path
    add_breadcrumb "<a href='#{profesor_student_path(@user)}'>#{@user.email}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{analytics_quiz_profesor_student_path(@user, quiz_id: @quiz)}'>Detalles de la evaluación</a>".html_safe
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

  def get_program_stat(user, program)
    ProgramStat.where(user_id: user.id, program_id: program.id).last
  end

  def get_program_active(user, program)
    ProgramActive.where(user_id: user.id, program_id: program.id).first
  end
end
