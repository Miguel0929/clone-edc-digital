class Mentor::RefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student
  before_action :my_students?, only: [:show, :edit]
  before_action :require_admin_or_mentor
  before_action :set_refilable, only: [:show, :edit, :update]
  before_action :set_template_refilable, only: [:plantilla, :record]

  helper_method :evaluation_pointed?
  helper_method :evaluation_result
  helper_method :evaluation_checked?

  add_breadcrumb "EDC DIGITAL", :root_path
  before_action :set_user_breadcrum

  def show
    @totaleval = @refilable.template_refilable.evaluation_refilables.sum(:points)
    @evaluations = @user.user_evaluation_refilables.joins(:evaluation_refilable).where('evaluation_refilables.template_refilable_id = ?', @refilable.template_refilable.id)
    add_breadcrumb "<a href='#{dashboard_template_refilables_path(user_id: @user.id)}'>Plantillas</a>".html_safe
    add_breadcrumb "<a class='active' href='#{mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe
  end

  def edit
    add_breadcrumb "<a class='active' href='#{edit_mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe
  end

  def update
    @refilable.update(refilable_params)
    @template_refilable = @refilable.template_refilable
    
    @user.refilable_notifications.create({ template_refilable_id: @template_refilable.id, notification_type: 1 })
    if @user.panel_notifications.refilable_commented.first.nil? || @user.panel_notifications.refilable_commented.first.status
      Refilables.commented(@template_refilable, @user, resume_dashboard_template_refilable_url(@template_refilable))
    end

    respond_to do |format|
      format.html { redirect_to :back, notice: 'Plantilla actualizada'}
      format.js { render "notification"}
      format.json { render json: @refilable, status: :update }
    end  
  end

  def plantilla
    add_breadcrumb "<a class='active' href='#{plantilla_mentor_student_refilable_path(@user, @template)}'>Visualización de plantilla: #{@template.name}</a>".html_safe
  end

  def record
    add_breadcrumb "<a class='active' href='#{record_mentor_student_refilable_path(@user, @template)}'>Historial de plantilla: #{@template.name}</a>".html_safe
    @refilables = @template.refilables.where(user: @user).order(:created_at)
    @refilable = @refilables.last
  end

  def evaluation_pointed?(evaluation, points)
    !@evaluations.where(evaluation_refilable_id: evaluation, points: points).empty?
  end

  def evaluation_result(chapter)
    (((chapter.evaluation_points * 100) / chapter.total_evaluations_points rescue 0) * chapter.points / 100)
  end

  def evaluation_checked?(user, evaluation)
    UserEvaluationRefilable.where(user_id: user, evaluation_refilable_id: evaluation).exists?
  end
  

  private
  def set_student
    @user = User.find(params[:student_id])
  end

  def set_refilable
    @refilable = Refilable.find(params[:id])
  end

  def set_template_refilable
    @template = TemplateRefilable.find(params[:id])
  end

  def refilable_params
    params.require(:refilable).permit(:comments)
  end

  def set_user_breadcrum
    if current_user.mentor?
      add_breadcrumb "#{@user.name}", mentor_student_path(@user)
    elsif current_user.admin?
      add_breadcrumb "#{@user.name}", user_path(@user)
    end  
  end

  def my_students?
    unless current_user.admin? || @user.my_student?(current_user) then redirect_to mentor_students_path, notice: "Este alumno no es parte de tus asesorados" end
  end
end
