class Dashboard::TemplateRefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  include ActiveElementsHelper
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    unless params[:user_id].present?
      if current_user.student? || current_user.mentor?
        @this_user = current_user
        add_breadcrumb "<a href='#{dashboard_template_refilables_path}' class='active'>Mis plantillas</a>".html_safe 
        @template_refilables = get_active_elements(current_user, "template_refilables")
      end
    else
      @student = User.find(params[:user_id])
      @this_user = @student
      add_breadcrumb "Estudiantes", :mentor_students_path
      add_breadcrumb "<a href='#{mentor_student_path(@student)}'>#{@student.email}</a>".html_safe
      add_breadcrumb "<a class='active' href='#{dashboard_template_refilables_path(user_id: @student.id)}'>Plantillas</a>".html_safe
      @template_refilables = @this_user.group.all_refilables
    end  

    if !params[:program_id].nil?
      @template_refilables = @template_refilables.select {|x| x['program_id'] == params[:program_id].to_i }
      @program = Program.find(params[:program_id])
    end

    @done_refilables = []
    @undone_refilables = []
    @template_refilables.each do |refil|
    	if refil.refilables.find_by(user: @this_user, draft: false)
    		@done_refilables.push(refil)
    	else
    		@undone_refilables.push(refil)
    	end
    end
  end

  def resume
    @template_refilable = TemplateRefilable.find(params[:id])
    @refilable = @template_refilable.refilables.where(user_id: current_user).order(:created_at).last
    @rubricas = @template_refilable.evaluation_refilables
    add_breadcrumb "Plantillas", :dashboard_template_refilables_path
    add_breadcrumb "<a class='active' href='#{resume_dashboard_template_refilable_path(@template_refilable)}'>Rúbrica de evaluación</a>".html_safe
  end 

  def evaluations
    add_breadcrumb "<a href='#{dashboard_template_refilables_path}'>Mis plantillas</a>".html_safe 
    add_breadcrumb "<a class='active' href='#{evaluations_dashboard_template_refilables_path}'>Evaluaciones de plantillas</a>".html_safe 
    template_ids = get_active_elements(current_user, "template_refilables").map{|t| t.id}
    @template_refilables = TemplateRefilable.where(id: template_ids).includes(:refilables).where(refilables: {user_id: current_user})
  end
end
