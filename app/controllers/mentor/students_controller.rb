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
  end
end
