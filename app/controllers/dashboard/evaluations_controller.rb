class Dashboard::EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program
  before_action :redirect_on_program_not_assigned

  helper_method :evaluation_pointed?

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path

  def index
    add_breadcrumb @program.name, dashboard_program_path(@program)
    add_breadcrumb "<a class='active' href='#{dashboard_evaluations_path(program_id: @program)}'>Rúbrica de evaluación</a>".html_safe

    @chapters = @program.chapters.select(
      "chapters.*,"\
      "(select COALESCE(SUM(user_evaluations.points), 0)  from user_evaluations where user_evaluations.user_id = #{current_user.id}  and user_evaluations.evaluation_id in (select id from evaluations where evaluations.chapter_id = chapters.id) ) as evaluation_points,"\
      "((select COUNT(*) from evaluations where evaluations.chapter_id = chapters.id) * 100) as total_evaluations_points"
    )
  end

  def show
    @chapter = Chapter.includes(:evaluations).find(params[:id])

    add_breadcrumb @program.name, dashboard_program_path(@program)
    add_breadcrumb 'Rúbrica de evaluación', dashboard_evaluations_path(program_id: @program)
    add_breadcrumb "<a class='active' href='#{dashboard_evaluation_path(@chapter, program_id: @program)}'>Resultados de evaluación</a>".html_safe


    @evaluations = current_user.user_evaluations.joins(:evaluation).where('evaluations.chapter_id = ?', 4)

    @answers = Question.select(
      "answers.*, questions.question_text, count(comments.id) as comments_count, (select id from chapter_contents where coursable_id = questions.id and coursable_type = 'Question' limit 1) as chapter_content_id"
    )
    .joins("left outer join answers on answers.question_id = questions.id and answers.user_id = #{current_user.id}")
    .joins('left join chapter_contents on chapter_contents.coursable_id = questions.id')
    .joins('left outer join comments on comments.answer_id = answers.id')
    .where('questions.id in (?) and chapter_contents.coursable_type = ?', @chapter.questions.pluck(:id), 'Question')
    .group('answers.id')
    .group('questions.id')
    .group('chapter_contents.position')
    .order('chapter_contents.position asc')
  end

  def evaluation_pointed?(evaluation, points)
    !current_user.user_evaluations.where(evaluation: evaluation, points: points).empty?
  end

  private
  def set_program
    @program = Program.includes(:chapters).find(params[:program_id])
  end

  def redirect_on_program_not_assigned
    redirect_to welcome_path unless current_user.group.programs.include?(@program)
  end
end
