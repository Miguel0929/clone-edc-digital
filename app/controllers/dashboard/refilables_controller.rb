class Dashboard::RefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  before_action :set_template_refilable
  before_action :redirect_to_template_refilables, if: :permiso_refilable
  add_breadcrumb "EDCDIGITAL", :root_path
  include TicketsHelper

  def new  
    if current_user.student?
      add_breadcrumb "Mis plantillas", dashboard_template_refilables_path
      add_breadcrumb "<a class='active' href='#{new_dashboard_template_refilable_refilable_path(@template)}'>#{@template.name}</a>".html_safe                           
    else
      @student = User.find(params[:user_id])
      add_breadcrumb "Estudiantes", :mentor_students_path
      add_breadcrumb "<a href='#{mentor_student_path(@student)}'>#{@student.email}</a>".html_safe
      add_breadcrumb "<a href='#{dashboard_template_refilables_path(user_id: @student.id)}'>Plantillas</a>".html_safe
      add_breadcrumb "<a class='active' href='#{new_dashboard_template_refilable_refilable_path(@template, user_id: @student.id)}'>#{@template.name}</a>".html_safe
    end
  end

  def create
    if @template.refilables.where(user_id: current_user.id).first.nil?
      refilable = @template.refilables.new(refilable_params)
      refilable.user = current_user
      if refilable.save
        create_ticket(current_user, refilable)
      end

      #AnsweredRefilableNotificationJob.perform_async(@template.program, @template, "soporte2@edc-digital.com", current_user, mentor_student_url(current_user))

      redirect_to dashboard_template_refilables_path, notice: 'Plantilla contestada'
    else
      redirect_to dashboard_template_refilables_path, alert: 'La plantilla ya estaba contestada previemiente.'
    end 
  end

  def show
    @refilable = Refilable.find(params[:id])
    add_breadcrumb "Mis plantillas", dashboard_template_refilables_path
    add_breadcrumb "<a class='active' href='#{dashboard_template_refilable_refilable_path(@template,  @refilable)}'>#{@template.name}</a>".html_safe                            

    @refilables = TemplateRefilable.joins(:groups)
                                    .where('groups.id = ?', current_user.group.id)
                                    .order(position: :asc)
    @done_refilables = []
    @undone_refilables = []
    @refilables.each do |refil|
      if refil.refilables.find_by(user: current_user)
        @done_refilables.push(refil)
      else
        @undone_refilables.push(refil)
      end
    end

  end

  def edit
    @refilable = Refilable.find(params[:id])

    add_breadcrumb "Mis plantillas", dashboard_template_refilables_path
    add_breadcrumb "<a class='active' href='#{edit_dashboard_template_refilable_refilable_path(@template,  @refilable)}'>#{@template.name}</a>".html_safe
  end

  def update
    @refilable = Refilable.find(params[:id])

    @refilable.update(refilable_params)

    redirect_to dashboard_template_refilable_refilable_path(@template,  @refilable)
  end

  private
  def set_template_refilable
    @template = TemplateRefilable.find(params[:template_refilable_id])
  end

  def refilable_params
    params.require(:refilable).permit(:content)
  end

  def permiso_refilable
    if current_user.student?
      !current_user.group.all_refilables.include?(@template)  
    else
      false
    end
  end  

  def redirect_to_template_refilables
    redirect_to dashboard_template_refilables_path, alert: 'No tienes asignada esta plantilla.' 
  end 
end
