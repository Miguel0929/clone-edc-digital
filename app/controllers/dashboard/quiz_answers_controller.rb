class Dashboard::QuizAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  before_action :set_quiz
  after_action :change_switch_evaluated, only: [:create]
  def create
    if params[:answers].map{ |a| a[1][:answer_text]}.include?(nil)
      redirect_to apply_dashboard_quiz_path(@quiz), alert: "debes contestar todas las preguntas"
    else
      if @quiz.answered(current_user) > 0
        @ans = QuizAnswer.where(quiz_question_id: @quiz.quiz_questions.map{ |q| q.id }, user_id: current_user.id)
        @ans.delete_all
      end
      Attempt.create(quiz_id: @quiz.id, user_id: current_user.id)
      params[:answers].each_with_index do |answer, index|
        answer_text = answer[1][:answer_text]
          if answer_text.class == Array

            answer_text.each do |a|
              answer[1][:correct] = a.split(' ~ ')[1] == 'correcta' ? true : false
              answer[1][:answer_text] = a.split(' ~ ')[0]
              QuizAnswer.create(answer_params(answer))
            end
          else
            answer[1][:correct] = answer[1][:answer_text].split(' ~ ')[1] == 'correcta' ? true : false 
            answer[1][:answer_text] = answer[1][:answer_text].split(' ~ ')[0]  
            QuizAnswer.create(answer_params(answer))
          end
      end
      redirect_to detail_dashboard_quiz_path(@quiz)
    end
  end

  private
    def set_quiz
      @quiz = Quiz.find(params[:quiz_id])
    end

    def build_question
      @quiz_question = QuizQuestion.find(params[:quiz_question_id] )
    end

    def build_answer
      @quiz_question.quiz_answers.find_by(user: current_user, quiz_question: @quiz_question) || @quiz_question.quiz_answers.new(user: current_user) 
    end

    def answer_params(custom_params)
      ActionController::Parameters.new(custom_params[1]).permit(:user_id, :quiz_question_id, :answer_text, :correct)
    end

  def change_switch_evaluated
    program_id = @quiz.program_id
    @user= current_user
    prog_stat = ProgramStat.where(user_id: @user.id, program_id: program_id).first
    
    unless program_id.nil?
      if prog_stat.nil?
        prog_stat = ProgramStat.create(user_id: @user.id, program_id: program_id)
      end
      program = Program.find(program_id)
      quizzes_program = Quiz.where(program_id: program.id)
      templates_program = TemplateRefilable.where(program_id: program.id)
      ##### Programs
      ids_rubricas = program.chapters.joins(:evaluations).select("evaluations.*").pluck("evaluations.id")
      c_rubricas = program.chapters.joins(:evaluations).select("evaluations.*").count
      c_user_evaluation =  UserEvaluation.where(evaluation_id: ids_rubricas, user_id: @user.id).count 
      ##### Templates
      ids_ev_refil = []
      c_evaluation_ref = 0
      templates_program.each do |template|
        ids_ev_refil += template.evaluation_refilables.pluck(:id)
        c_evaluation_ref += template.evaluation_refilables.count
      end
      c_user_evaluation_ref = UserEvaluationRefilable.where(evaluation_refilable_id: ids_ev_refil, user_id: @user.id).count 
      #####Quizzes
      c_quizzes = 0
      c_quizzes_answered = 0
      quizzes_program.each do |quiz|
        c_quizzes += 1
        if quiz.answered?(@user)
          c_quizzes_answered += 1
        end 
      end
      #####Evaluacion
      if c_rubricas == c_user_evaluation && c_evaluation_ref == c_user_evaluation_ref && c_quizzes == c_quizzes_answered #&& c_quizzes > 0 && c_rubricas > 0 && c_evaluation_ref > 0
        prog_stat.update(checked: true)
      end  
    end 
  end
end
