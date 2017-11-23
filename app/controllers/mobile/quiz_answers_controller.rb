class Mobile::QuizAnswersController < Mobile::BaseController
  before_action :authorize
  before_action :set_quiz

  def create
    if @quiz.answered(current_user) > 0
      @ans = QuizAnswer.where(quiz_question_id: @quiz.quiz_questions.map{ |q| q.id }, user_id: current_user.id)
      @ans.delete_all
    end

    begin
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
    rescue
      return redirect_to apply_mobile_quiz_path(@quiz, user_email: params[:user_email], user_token: params[:user_token]), notice: 'Todas las respuestas son obligatorias'
    end

    redirect_to detail_mobile_quiz_path(@quiz, user_email: params[:user_email], user_token: params[:user_token])
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
end
