class TemplateRefilablesController < ApplicationController
  before_action :set_template_refilable, only: [:show, :edit, :update, :destroy]

  def index
    @template_refilables = TemplateRefilable.all
  end

  def show
  end

  def new
    @template_refilable = TemplateRefilable.new
  end

  def edit
  end

  def create
    @template_refilable = TemplateRefilable.new(template_refilable_params)

    if @template_refilable.save
      redirect_to template_refilables_path, notice: 'Rellenable creado'
    else
      render :new
    end
  end

  def update
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
