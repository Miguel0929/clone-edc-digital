class Mentor::EvaluationRefilablesController < ApplicationController
	before_action :authenticate_user!
  before_action :require_admin_or_mentor
  before_action :set_user
  def update
  	@template_refilable = TemplateRefilable.find(params[:template_id])

    new_eval = EvaluatorRefilables.for(@user, params[:evaluation])
   
    if new_eval.nil?
      redirect_to :back, alert: "Debes evaluar todas las rúbricas"
    else
   	  @user.refilable_notifications.create({ template_refilable_id: @template_refilable.id, notification_type: 0 })
      #if @user.panel_notifications.up_rubric.first.nil? || @user.panel_notifications.up_rubric.first.status
      #  Programs.up_rubric(@program, @user, resume_dashboard_program_url(@program))
      #end  
      redirect_to :back, notice: "Evaluación exitosamente guardada"
    end
  end

  private
  def set_user
    @user = User.includes(:user_evaluation_refilables).find(params[:user_id])
  end
end
