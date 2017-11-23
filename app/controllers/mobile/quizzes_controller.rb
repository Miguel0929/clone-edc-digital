class Mobile::QuizzesController < Mobile::BaseController
  before_action :authorize
  layout 'mobile'
  skip_after_action :intercom_rails_auto_include
  helper_method :right_answer
  helper_method :evaluating_quiz

  def index
    quizzes = current_user.group.quizzes.map {|quizz| serialize_quizz(quizz)}

    render json: quizzes
  end

  def apply
    @answers = []
    @quiz = Quiz.find(params[:id])
    @quiz.quiz_questions.each do |question|
      @answers << QuizAnswer.new(quiz_question_id: question.id, user_id: current_user.id)
    end
    if @quiz.answered(current_user) > 0
      flash[:notice] = "Este es tu intento número #{Attempt.where(quiz_id: @quiz.id, user_id: current_user.id).count + 1} la calificación que obtengas será la se tomará en cuenta"
    end
  end

  def detail
    @quiz = Quiz.find(params[:id])
    ids = @quiz.quiz_questions.map{ |q| q.id }
    @answers = QuizAnswer.where(quiz_question_id: ids, user_id: current_user.id)
  end
  
  def evaluating_quiz(rightones, yours)
    result = nil
    rightones.each do |rightone|
      if rightone == yours
        result = true
        break
      else
        result = false
      end
    end
    return result
  end

  def right_answer(question)
    options = QuizQuestion.find(question).answer_options.split /[\r\n]+/
    righty = [];

    options.each do |option|
      if option.include? "~ correcta" then righty << option.chomp(" ~ correcta") end
    end
    return righty
  end

  private

  def serialize_quizz(quizz)
    quizz_hash = quizz.attributes
    quizz_hash[:attempts] = Attempt.where(quiz_id: quizz[:id], user_id: current_user.id)
    quizz_hash
  end
end
