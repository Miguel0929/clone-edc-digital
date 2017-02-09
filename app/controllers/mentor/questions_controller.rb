class Mentor::QuestionsController < ApplicationController
  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Estudiantes", :mentor_students_path

  def show
    @question = Question.find(params[:id])
    @user = User.find(params[:user_id])
    @answer = Answer.find_by(user: @user, question: @question)
    @comments = @question.comments.includes(:user).where(owner: @user).order(created_at: :asc)

    add_breadcrumb @user.email, mentor_student_path(@user)
  end
end
