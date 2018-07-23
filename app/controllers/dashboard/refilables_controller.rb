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
 
    user_refilables = @template.refilables.where(user_id: current_user.id, draft: false)
    refilable_draft = 
    if user_refilables.count > 4
      user_refilables.order(:created_at).first.destroy
    end

    if params[:draft] == 'true'
      refilable = Refilable.find_or_initialize_by(user_id: current_user.id, template_refilable_id: @template.id, draft: true)
      refilable.content = refilable_params[:content]
      refilable.draft = params[:draft] 
      mensaje = "Borrador de la plantilla #{@template.name} guardado."
    else
      refilable = @template.refilables.new(refilable_params)
      refilable.draft = params[:draft]
      #if params[:refilable_content]
      #  refilable = @template.refilables.new(content: params[:refilable_content])
      #else
      #  refilable = @template.refilables.new(refilable_params)
      #end
      mensaje = 'Felicidades por haber contestado tu plantilla. En un máximo de 72 horas recibirás respuesta de los mentores Te pedimos paciencia'  
    end    
    refilable.user = current_user
 
    if refilable.save
      if refilable.draft == false
        ticket = Ticket.find_by(trainee_id: current_user.id, category: 1, element_id: @template.id)
        if ticket.nil?
          create_ticket(current_user, refilable)
        else
          open_ticket(current_user, @template)
        end
        AnsweredRefilableNotificationJob.perform_async(@template.program, @template, "soporte2@edc-digital.com", current_user, mentor_student_url(current_user))
        if params["is-draft"].present?
          Refilable.where(user_id: current_user.id, template_refilable_id: @template.id, draft: true).destroy_all
        end
      end
      
      redirect_to dashboard_template_refilables_path, notice: mensaje
    else
      redirect_to dashboard_template_refilables_path, alert: 'Error al guardar respuestas, intenta de nuevo'
    end 
  end

  def show
    @refilable = Refilable.find(params[:id])
    add_breadcrumb "Mis plantillas", dashboard_template_refilables_path
    add_breadcrumb "<a class='active' href='#{dashboard_template_refilable_refilable_path(@template,  @refilable)}'>#{@template.name}</a>".html_safe 

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
