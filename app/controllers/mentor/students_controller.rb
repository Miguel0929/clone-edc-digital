class Mentor::StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentor_students_path}'>Estudiantes</a>".html_safe

    @users = User.students_table.where('users.id in (?)', current_user.groups.joins(:active_students).pluck('users.id'))
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
end
