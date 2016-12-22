class Mentors::EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_user
  before_action :set_program

  helper_method :evaluation_pointed?

  def index
    @chapters = @program.chapters.select(
      "chapters.*,"\
      "(select COALESCE(SUM(user_evaluations.points), 0)  from user_evaluations where user_evaluations.user_id = #{@user.id}  and user_evaluations.evaluation_id in (select id from evaluations where evaluations.chapter_id = chapters.id) ) as evaluation_points,"\
      "((select COUNT(*) from evaluations where evaluations.chapter_id = chapters.id) * 100) as total_evaluations_points"
    )
  end

  def show
    @chapter = Chapter.includes(:evaluations).find(params[:id])

    @evaluations = @user.user_evaluations.joins(:evaluation).where('evaluations.chapter_id = ?', 4)

    @answers = Answer.select(
      "answers.*, questions.question_text, count(comments.id) as comments_count, (select id from chapter_contents where coursable_id = questions.id and coursable_type = 'Question' limit 1) as chapter_content_id"
    )
    .joins(:question)
    .joins('left outer join comments on comments.answer_id = answers.id')
    .where('answers.question_id in (?) and answers.user_id = ?', @chapter.questions.pluck(:id), @user.id)
    .group('questions.id')
    .group('answers.id')
  end

  def update
    @chapter = Chapter.find(params[:id])

    Evaluator.for(@user, params[:evaluation])

    redirect_to mentors_evaluation_path(@chapter, user_id: @user, program_id: @program)
  end

  def evaluation_pointed?(evaluation, points)
    !@evaluations.where(evaluation: evaluation, points: points).empty?
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_program
    @program = Program.includes(:chapters).find(params[:program_id])
  end
end
