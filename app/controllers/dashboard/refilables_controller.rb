class  Dashboard::RefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  before_action :set_template_refilable
  before_action :redirect_to_template_refilables, if: :permiso_refilable
  add_breadcrumb "EDCDIGITAL", :root_path

  def new
    add_breadcrumb "Mis rellenables", dashboard_template_refilables_path
    add_breadcrumb "<a class='active' href='#{new_dashboard_template_refilable_refilable_path(@template)}'>#{@template.name}</a>".html_safe
  end

  def create
    refilable = @template.refilables.new(refilable_params)
    refilable.user = current_user
    refilable.save

    redirect_to dashboard_template_refilables_path, notice: 'Rellenable contestado'
  end

  def show
    @refilable = Refilable.find(params[:id])

    add_breadcrumb "Mis rellenables", dashboard_template_refilables_path
    add_breadcrumb "<a class='active' href='#{dashboard_template_refilable_refilable_path(@template,  @refilable)}'>#{@template.name}</a>".html_safe
  end

  def edit
    @refilable = Refilable.find(params[:id])

    add_breadcrumb "Mis rellenables", dashboard_template_refilables_path
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
    !current_user.group.all_refilables.include?(@template)  
  end  

  def redirect_to_template_refilables
    redirect_to dashboard_template_refilables_path, alert: 'No tienes asignado este rellenable' 
  end 
end
