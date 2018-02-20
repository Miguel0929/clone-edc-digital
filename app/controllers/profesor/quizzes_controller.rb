class Profesor::QuizzesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_quiz, only: [:apply]
	def apply
    @answers = []
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: current_user.id)
    end
    if @quiz.answered(current_user) > 0
      flash[:notice] = "Este es tu intento número #{Attempt.where(quiz_id: @quiz.id, user_id: current_user.id).count + 1} la calificación que obtengas será la se tomará en cuenta"
    end

    student = User.find(params[:user_id])
    add_breadcrumb "Estudiantes", :profesor_students_path
    add_breadcrumb "<a href='#{profesor_student_path(student)}'>#{student.email}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{apply_profesor_quiz_path(@quiz, user_id: params[:user_id])}'>#{@quiz.name}</a>".html_safe
  end

  private
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end
end
