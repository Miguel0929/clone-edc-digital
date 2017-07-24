class  Dashboard::RefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template_refilable
  add_breadcrumb "EDCDIGITAL", :root_path

  def new
  end

  def create
    refilable = @template.refilables.new(refilable_params)
    refilable.user = current_user
    refilable.save

    redirect_to dashboard_template_refilables_path, notice: 'Rellenable contestado'
  end

  def show
    @refilable = Refilable.find(params[:id])
  end

  def edit
    @refilable = Refilable.find(params[:id])
  end

  def update
    @refilable = Refilable.find(params[:id])
  end

  private
  def set_template_refilable
    @template = TemplateRefilable.find(params[:template_refilable_id])
  end

  def refilable_params
    params.require(:refilable).permit(:content)
  end
end
