class Mentor::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentor_students_path}'>Estudiantes</a>".html_safe

    @users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
      .page(params[:page]).per(100)

    if params[:state].present?
      case params[:state]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    if params[:answered].present?
      @users = @users.select do |user|
        percentage = (user.answers_count * 100) / user.questions_count rescue 0
        percentage_condition(percentage, params[:answered].to_i)
      end
    end

    if params[:visited].present?
      @users = @users.select do |user|
        percentage = (user.content_tracked_count * 100) / user.content_count rescue 0
        percentage_condition(percentage, params[:visited].to_i)
      end
    end

    @users = @users.where(group: params[:group]) if params[:group].present?
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
end
