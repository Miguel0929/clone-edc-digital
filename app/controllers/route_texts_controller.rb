class RouteTextsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_text, only: [:edit, :show, :update, :destroy]

  add_breadcrumb "EDC DIGITAL", :root_path

  def index
  	@routetexts = RouteText.all
  end

  def show
  end

  def new
  	@routetext = RouteText.new
  end

  def create
	@routetext = RouteText.new(text_params)

    if @routetext.save
      redirect_to dashboard_pathway_path, notice: "Se creó exitosamente el texto #{@routetext.name}"
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @routetext.update(text_params)
      redirect_to dashboard_pathway_path(@routetext), notice: "Se actualizó exitosamente el texto #{@routetext.name}"
	else
	  render :edit
	end	
  end

  def destroy
  	@routetext.destroy
	redirect_to dashboard_pathway_path, notice: "Se eliminó exitosamente el texto #{@routetext.name}"
  end

  private
  def text_params
	params.require(:route_text).permit(:name, :redaction)
  end

  def set_text
	@routetext = RouteText.find(params[:id])
  end
end
