class Mentor::QuizzesController < ApplicationController
	before_action :set_student
	before_action :set_quiz
	def show
		@answers = []
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: @user.id)
    end
    if @quiz.answered(@user) > 0
      flash[:notice] = "Este es tu intento número #{Attempt.where(quiz_id: @quiz.id, user_id: current_user.id).count + 1} la calificación que obtengas será la se tomará en cuenta"
    end
      
    add_breadcrumb "Estudiantes", :mentor_students_path
    add_breadcrumb "<a href='#{mentor_student_path(@user)}'>#{@user.email}</a>".html_safe
    add_breadcrumb "<a href='#{dashboard_quizzes_path(user_id: @user.id)}'>Evaluaciones</a>".html_safe
    add_breadcrumb "<a class='active' href='#{dashboard_quiz_path(@quiz, user_id: @user.id)}'>#{@quiz.name}</a>".html_safe
	end	
	private
  def set_student
    @user = User.find(params[:student_id])
  end

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end
end
