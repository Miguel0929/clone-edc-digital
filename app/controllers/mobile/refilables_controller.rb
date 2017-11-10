class Mobile::RefilablesController < Mobile::BaseController
  #before_action :authorize
  before_action :set_template_refilable
  layout 'mobile'
  skip_after_action :intercom_rails_auto_include

  def new
  end

  def create
    refilable = @template.refilables.new(refilable_params)
    refilable.user = current_user
    refilable.save

    redirect_to edit_mobile_template_refilable_refilable_path(@template, refilable)
  end

  def edit
    @refilable = Refilable.find(params[:id])
  end

  def update
    @refilable = Refilable.find(params[:id])

    @refilable.update(refilable_params)

    redirect_to edit_mobile_template_refilable_refilable_path(@template, @refilable)
  end

  private
  def set_template_refilable
    @template = TemplateRefilable.find(params[:template_refilable_id])
  end

  def refilable_params
    params.require(:refilable).permit(:content)
  end
end
