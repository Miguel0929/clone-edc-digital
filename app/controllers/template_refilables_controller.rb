class TemplateRefilablesController < ApplicationController
  before_action :set_template_refilable, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{template_refilables_path}'>Mis rellenables</a>".html_safe

    @template_refilables = TemplateRefilable.all
  end

  def show
    add_breadcrumb "EDCDIGITAL", :root_path
    add_breadcrumb "Mis rellenables", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe
  end

  def new
    add_breadcrumb "EDCDIGITAL", :root_path
    add_breadcrumb "Mis rellenables", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{new_template_refilable_path}'>Nuevo rellenable</a>".html_safe

    @template_refilable = TemplateRefilable.new
  end

  def edit
    add_breadcrumb "EDCDIGITAL", :root_path
    add_breadcrumb "Mis rellenables", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{edit_template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe
  end

  def create
    add_breadcrumb "EDCDIGITAL", :root_path
    add_breadcrumb "Mis rellenables", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{new_template_refilable_path}'>Nuevo rellenable</a>".html_safe

    @template_refilable = TemplateRefilable.new(template_refilable_params)

    if @template_refilable.save
      redirect_to template_refilables_path, notice: 'Rellenable creado'
    else
      render :new
    end
  end

  def update
    add_breadcrumb "EDCDIGITAL", :root_path
    add_breadcrumb "Mis rellenables", :template_refilables_path
    add_breadcrumb "<a class='active' href='#{edit_template_refilable_path(@template_refilable)}'>#{@template_refilable.name}</a>".html_safe

    if @template_refilable.update(template_refilable_params)
      redirect_to template_refilables_path, notice: 'Rellenable actualizado'
    else
      render :edit
    end
  end

  def destroy
    @template_refilable.destroy
    redirect_to template_refilables_path, notice: 'Rellenable eliminado'
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
      params.require(:template_refilable).permit(:name, :description, :content, group_ids: [])
    end
end
