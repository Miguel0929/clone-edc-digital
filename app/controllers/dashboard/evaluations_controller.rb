class Dashboard::EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group? 
  before_action :set_program
  before_action :redirect_on_program_not_assigned

  helper_method :evaluation_pointed?
  helper_method :evaluation_result
  helper_method :evaluation_checked?
  include EvaluationHelper

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  add_breadcrumb "Programas", :dashboard_programs_path

  def index
    add_breadcrumb @program.name, dashboard_program_path(@program)
    add_breadcrumb "<a class='active' href='#{dashboard_evaluations_path(program_id: @program)}'>Evaluación de programa</a>".html_safe

    @user = current_user
    @chapters = @program.chapters.select(
      "chapters.*,"\
      "(select COALESCE(SUM(user_evaluations.points), 0)  from user_evaluations where user_evaluations.user_id = #{current_user.id}  and user_evaluations.evaluation_id in (select id from evaluations where evaluations.chapter_id = chapters.id) ) as evaluation_points,"\
      "((select COUNT(*) from evaluations where evaluations.chapter_id = chapters.id) * 100) as total_evaluations_points"
    )
    question_contents = ChapterContent.joins(:chapter => :program).where(programs: {id: @program.id}).where(coursable_type: "Question")
    @chapter_w_questions = question_contents.map {|cont| cont.chapter.id}.uniq
    @answers_total, @rubrics_checked = 0, 0
    @chapters.each do |chapter|
      if chapter.questions.count > 0 then @answers_total += answered_questions(chapter, @user) end
      if chapter.evaluations.exists?
        chapter.evaluations.each do |evaluation|
          if evaluation_checked?(@user, evaluation) == true then @rubrics_checked += 1 end
        end
      end
    end
  end

  def show
    @chapter = Chapter.includes(:evaluations).find(params[:id])

    add_breadcrumb @program.name, dashboard_program_path(@program)
    add_breadcrumb 'Rúbrica de evaluación', dashboard_evaluations_path(program_id: @program)
    add_breadcrumb "<a class='active' href='#{dashboard_evaluation_path(@chapter, program_id: @program)}'>Evaluación de módulo</a>".html_safe


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

    if @answers.exists?
      @ans_ary = []
      @answers.map { |answer| if !answer.answer_text.nil? then @ans_ary << answer.answer_text else @ans_ary << 0 end }
    end

    if @chapter.evaluations.exists?
      @evals_ary = []
      @chapter.evaluations.map { |evalue| if evaluation_pointed?(evalue, 100) then @evals_ary << 100 elsif evaluation_pointed?(evalue, 75) then @evals_ary << 75 elsif evaluation_pointed?(evalue, 50) then @evals_ary << 50 elsif evaluation_pointed?(evalue, 25) then @evals_ary << 25 else  @evals_ary << 0 end }
    end
  end

  def evaluation_pointed?(evaluation, points)
    !current_user.user_evaluations.where(evaluation: evaluation, points: points).empty?
  end

  def evaluation_result(chapter)
    (((chapter.evaluation_points * 100) / chapter.total_evaluations_points rescue 0) * chapter.points / 100)
  end

  def evaluation_checked?(user, evaluation)
    UserEvaluation.where(user_id: user, evaluation_id: evaluation).exists?
  end

  private
  def set_program
    @program = Program.includes(:chapters).find(params[:program_id])
  end

  def redirect_on_program_not_assigned
    redirect_to welcome_path unless current_user.group.all_programs.include?(@program)
  end
end
