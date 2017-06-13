class Mentor::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  add_breadcrumb "EDCDIGITAL", :root_path
  helper_method :get_program_stat

  def index
    add_breadcrumb "<a class='active' href='#{mentor_students_path}'>Estudiantes</a>".html_safe

    #@users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
    #  .page(params[:page]).per(100)

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
      @users = @users.joins(:group).where(groups: {university: params[:university]})
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
    @users = @users.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id')).search(params[:query]) if params[:query].present?
  end


  def show
    @user = User.find(params[:id])

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
  end

  def exports
    @users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id')) 
    respond_to do |format|
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="Lista de alumnos.xlsx"'} 
    end
  end

  def analytics_quiz
    @quiz = Quiz.find(params[:quiz_id])
    @user = User.find(params[:id])
    add_breadcrumb "Estudiantes", :mentor_students_path
    add_breadcrumb "<a href='#{mentor_student_path(@user)}'>#{@user.email}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{analytics_quiz_mentor_student_path(@user, quiz_id: @quiz)}'>Detalles del exámen</a>".html_safe
  end

  def get_program_stat(user, program)
    ProgramStat.where(user_id: user.id, program_id: program.id).last
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
end
