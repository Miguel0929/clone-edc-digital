class Profesor::EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_profesor
  before_action :set_user
  before_action :set_program
  before_action :set_chapters

  include EvaluationHelper
  helper_method :evaluation_pointed?
  helper_method :evaluation_result
  helper_method :evaluation_checked?


  add_breadcrumb "EDC DIGITAL", :root_path
  add_breadcrumb "Estudiantes", :profesor_students_path

  def index

    add_breadcrumb @user.email, profesor_student_path(@user)
    add_breadcrumb "<a class='active' href='#{profesor_evaluations_path(program_id: @program, user_id: @user)}'>Evaluación de programa</a>".html_safe

    @answers_total, @rubrics_checked = 0, 0
    @chapters.each do |chapter|
      if chapter.questions.count > 0 then @answers_total += answered_questions(chapter, @user) end
      if chapter.evaluations.exists?
        chapter.evaluations.each do |evaluation|
          if evaluation_checked?(@user, evaluation) == true then @rubrics_checked += 1 end
        end
      end
    end
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
    @templates = TemplateRefilable.where(id: @chapter.template_refilables.pluck(:id))
    dp = DelireverablePackage.where(id: @chapter.delireverable_packages.pluck(:id)).pluck(:id)
    @delireverables = Delireverable.where(delireverable_package_id: dp)
    @quizzes = Quiz.where(id: @chapter.quizzes.pluck(:id))
    
    @chapters_w_questions = []
    @chapters.all.map { |chap| if (chap.questions.count >0 || chap.quizzes.count > 0 || chap.delireverable_packages.count > 0 || chap.delireverable_packages.count > 0 || chap.template_refilables.count > 0 ) then @chapters_w_questions << chap end}
 
    @chapters_w_questions.each_with_index do |chapter, index|
      if chapter.id == @chapter.id
        nav_indexes = user_spot
        @prev_student, @next_student = User.find(nav_indexes[0]), User.find(nav_indexes[1])
        if index == 0 
          @prev_chapter, @next_chapter = @chapter, @chapters_w_questions[index+1] 
          @selected_user = @prev_student
          @same_user_next = @user
          @prev_text = "Estudiante anterior: "
        elsif index == (@chapters_w_questions.count - 1)
          @prev_chapter, @next_chapter = @chapters_w_questions[index-1], @chapters_w_questions[0] #@chapters_w_questions[@chapters_w_questions.count - 1]  -> NOTA: "@next_chapter" ya no será el último si no el primero del sig usuario
          @selected_user = @next_student
          @next_text = "Siguiente estudiante: "
          @same_user_prev = @user
        else 
          @prev_chapter, @next_chapter = @chapters_w_questions[index-1], @chapters_w_questions[index+1]
          @selected_user = @user
        end
      end
    end

    add_breadcrumb 'Evaluación de programa', profesor_evaluations_path(program_id: @program, user_id: @user)
    add_breadcrumb "<a class='active' href='#{profesor_evaluation_path(@chapter, program_id: @program, user_id: @user)}'>Evaluación de programa</a>".html_safe
  end	

  def evaluation_result(chapter)
    (((chapter.evaluation_points * 100) / chapter.total_evaluations_points rescue 0) * chapter.points / 100)
  end

  def evaluation_checked?(user, evaluation)
    UserEvaluation.where(user_id: user, evaluation_id: evaluation).exists?
  end

  def evaluation_pointed?(evaluation, points)
    !@evaluations.where(evaluation: evaluation, points: points).empty?
  end

  private
  def set_user
    @user = User.includes(:user_evaluations).find(params[:user_id])
  end

  def set_program
    @program = Program.includes(:chapters).find(params[:program_id])
  end

  def set_chapters
    @chapters = @program.chapters.select(
      "chapters.*,"\
      "(select COALESCE(SUM(user_evaluations.points), 0)  from user_evaluations where user_evaluations.user_id = #{@user.id}  and user_evaluations.evaluation_id in (select id from evaluations where evaluations.chapter_id = chapters.id) ) as evaluation_points,"\
      "((select COUNT(*) from evaluations where evaluations.chapter_id = chapters.id) * 100) as total_evaluations_points"
    )
  end

  def user_spot
    ordered_students = @user.group.active_students.order(:id).pluck(:id)
    current_position = ordered_students.index(@user.id)
    if ordered_students.count > 1
      if current_position == 0
        prev_student = ordered_students[current_position]
        next_student = ordered_students[current_position + 1]
      elsif (current_position + 1) == ordered_students.size
        prev_student = ordered_students[current_position - 1]
        next_student = ordered_students[current_position]
      else
        prev_student = ordered_students[current_position - 1]
        next_student = ordered_students[current_position + 1]
      end
    else
      prev_student = ordered_students[current_position]
      next_student = ordered_students[current_position]
    end
    return prev_student, next_student
  end
end  	