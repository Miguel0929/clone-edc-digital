class Mentor::EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor
  before_action :set_user
  before_action :set_program

  helper_method :evaluation_pointed?
  helper_method :evaluation_result
  helper_method :evaluation_checked?

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Estudiantes", :mentor_students_path

  def index
    if current_user.admin?
      add_breadcrumb @user.email, user_path(@user)
    else
      add_breadcrumb @user.email, mentor_student_path(@user)
    end
    add_breadcrumb "<a class='active' href='#{mentor_evaluations_path(program_id: @program, user_id: @user)}'>Evaluación de programa</a>".html_safe

    @chapters = @program.chapters.select(
      "chapters.*,"\
      "(select COALESCE(SUM(user_evaluations.points), 0)  from user_evaluations where user_evaluations.user_id = #{@user.id}  and user_evaluations.evaluation_id in (select id from evaluations where evaluations.chapter_id = chapters.id) ) as evaluation_points,"\
      "((select COUNT(*) from evaluations where evaluations.chapter_id = chapters.id) * 100) as total_evaluations_points"
    )
    respond_to do |format|
      format.html
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="evaluar_modulo.xlsx"'}
    end
  end

  def show
    @chapter = Chapter.includes(:evaluations).find(params[:id])

    allevals = @chapter.evaluations
    @totaleval = allevals.map { |evaluation| evaluation.points }.inject(0, :+) 

    @evaluations = @user.user_evaluations.joins(:evaluation).where('evaluations.chapter_id = ?', @chapter.id)

    @answers = Question.select(
      "answers.*, questions.id as question_id, questions.question_text, count(comments.id) as comments_count, (select id from chapter_contents where coursable_id = questions.id and coursable_type = 'Question' limit 1) as chapter_content_id"
    )
    .joins("left outer join answers on answers.question_id = questions.id and answers.user_id = #{@user.id}")
    .joins('left join chapter_contents on chapter_contents.coursable_id = questions.id')
    .joins("left outer join comments on comments.question_id = questions.id and comments.owner_id = #{@user.id}")
    .where('questions.id in (?) and chapter_contents.coursable_type = ?', @chapter.questions.pluck(:id), 'Question')
    .group('answers.id')
    .group('questions.id')
    .group('chapter_contents.position')
    .order('chapter_contents.position asc')

    if current_user.admin?
      add_breadcrumb @user.email, user_path(@user)
    else
      add_breadcrumb @user.email, mentor_student_path(@user)
    end
    add_breadcrumb 'Evaluación de programa', mentor_evaluations_path(program_id: @program, user_id: @user)
    add_breadcrumb "<a class='active' href='#{mentor_evaluation_path(@chapter, program_id: @program, user_id: @user)}'>Evaluación de programa</a>".html_safe
  end

  def update
    @chapter = Chapter.find(params[:id])

    new_eval = Evaluator.for(@user, params[:evaluation])
    
    if new_eval.nil?
      redirect_to mentor_evaluation_path(@chapter, user_id: @user, program_id: @program), alert: "Debes evaluar todas las rúbricas"
    else
      if params[:path] == "store"
        @user.program_notifications.create({ program_id: @program.id, notification_type: 0 })
        redirect_to mentor_evaluation_path(@chapter, user_id: @user, program_id: @program), notice: "Evaluación exitosamente guardada"
      else
        @user.program_notifications.create({ program_id: @program.id, notification_type: 0 })
        redirect_to mentor_evaluations_path(user_id: @user, program_id: @program), notice: "Evaluación exitosamente guardada"
      end
    end
  end

  def evaluation_pointed?(evaluation, points)
    !@evaluations.where(evaluation: evaluation, points: points).empty?
  end

  def evaluation_result(chapter)
    (((chapter.evaluation_points * 100) / chapter.total_evaluations_points rescue 0) * chapter.points / 100)
  end

  def evaluation_checked?(user, evaluation)
    UserEvaluation.where(user_id: user, evaluation_id: evaluation).exists?
  end

  private
  def set_user
    @user = User.includes(:user_evaluations).find(params[:user_id])
  end

  def set_program
    @program = Program.includes(:chapters).find(params[:program_id])
  end
end
