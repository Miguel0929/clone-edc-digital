class QuizQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_quiz, only: [:new, :create, :destroy, :edit, :update]

  def new
    @quiz_question = @quiz.quiz_questions.build
  end

  def edit
    @quiz_question = QuizQuestion.find(params[:id])
  end

  def create
    @quiz_question = QuizQuestion.new(quiz_question_params)
    if @quiz_question.save
      redirect_to @quiz
    else
      render :new
    end
  end

  def update
    @quiz_question = QuizQuestion.find(params[:id])
    if @quiz_question.update(quiz_question_params)
      redirect_to @quiz
    else
      render :edit
    end
  end

  def destroy
    @quiz_question = QuizQuestion.find(params[:id])
    @quiz_question.destroy
    redirect_to @quiz
  end

  private
    def set_quiz
      @quiz = Quiz.find(params[:quiz_id])
    end

    def quiz_question_params
      params.require(:quiz_question).permit(:question_type, :question_text, :position, :answer_options, :support_text, :quiz_id, :points)
    end
end
