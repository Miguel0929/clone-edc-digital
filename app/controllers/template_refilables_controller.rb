class TemplateRefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template_refilable, only: [:show, :edit, :update, :destroy, :rubrics]
  before_action :require_admin, except: [:show]
  before_action :require_admin_or_mentor_or_profesor, only: [:show]
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{template_refilables_path}'>Mis plantillas</a>".html_safe

    @template_refilables = TemplateRefilable.all.includes(:program).order(position: :asc)
  end

  def show
    add_breadcrumb "Mis plantillas", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe
  end

  def new
    add_breadcrumb "Mis plantillas", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{new_template_refilable_path}'>Nueva plantilla</a>".html_safe

    @template_refilable = TemplateRefilable.new
  end

  def edit
    add_breadcrumb "Mis plantillas", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{edit_template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe
  end

  def rubrics
    add_breadcrumb "<a href='#{template_refilables_path}'>Plantillas</a>".html_safe
    add_breadcrumb "<a href='#{template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{rubrics_template_refilable_path(@template_refilable)}'>Rubricas</a>".html_safe
  end  

  def create
    add_breadcrumb "Mis plantillas", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{new_template_refilable_path}'>Nueva plantilla</a>".html_safe

    @template_refilable = TemplateRefilable.new(template_refilable_params)
    @template_refilable.tipo=1

    if @template_refilable.save
      redirect_to template_refilables_path, notice: 'Plantilla creada'
    else
      render :new
    end
  end

  def update
    add_breadcrumb "Mis plantillas", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{edit_template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe

    if @template_refilable.update(template_refilable_params)
      redirect_to template_refilables_path, notice: 'Plantilla actualizada'
    else
      render :edit
    end
  end

  def destroy
    @template_refilable.destroy
    redirect_to template_refilables_path, notice: 'Plantilla eliminada'
  end

  def sort
    params[:template_refilable].each_with_index do |id, index|
      TemplateRefilable.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
  end


  private
    def set_template_refilable
      @template_refilable = TemplateRefilable.find(params[:id])
    end

    def template_refilable_params
      params.require(:template_refilable).permit(:name, :description, :content, :program_id, group_ids: [], evaluation_refilables_attributes: [
      :id, :name, :points, :position, :excelent, :good, :regular, :bad, :_destroy])
    end
end
