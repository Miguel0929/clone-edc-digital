class Mentor::EvaluationRefilablesController < ApplicationController
	before_action :authenticate_user!
  before_action :require_admin_or_mentor
  before_action :set_user
  after_action :change_switch_evaluated, only: [:update]
  include TicketsHelper
  
  def update
  	@template_refilable = TemplateRefilable.find(params[:template_id])

    new_eval = EvaluatorRefilables.for(@user, params[:refilable_id], params[:evaluation])
   
    if new_eval.nil?
      redirect_to :back, alert: "Debes evaluar todas las rúbricas"
    else
      close_ticket(@user, @template_refilable)
   	  @user.refilable_notifications.create({ template_refilable_id: @template_refilable.id, notification_type: 0 })
      if @user.panel_notifications.refilable_evaluated.first.nil? || @user.panel_notifications.refilable_evaluated.first.status
        Refilables.up_rubric(@template_refilable, @user, resume_dashboard_template_refilable_url(@template_refilable))
      end  
      redirect_to :back, notice: "Evaluación exitosamente guardada"
    end
  end

  private
  def set_user
    @user = User.includes(:user_evaluation_refilables).find(params[:user_id])
  end

  def change_switch_evaluated
    program_id = @template_refilable.program_id
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
      if c_rubricas == c_user_evaluation && c_evaluation_ref == c_user_evaluation_ref && c_quizzes == c_quizzes_answered #&& c_quizzes > 0 && c_rubricas > 0 && c_evaluation_ref > 0
        prog_stat.update(checked: true)
      end  
    end 
  end
end
