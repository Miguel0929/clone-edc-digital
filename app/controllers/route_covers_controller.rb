class RouteCoversController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cover, only: [:show, :destroy, :update, :edit]

  
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
  	@routecovers = RouteCover.all
  end

  def show
  end

  def new
  	@routecover = RouteCover.new
  end

  def create
	@routecover = RouteCover.new(cover_params)

    if @routecover.save
      redirect_to dashboard_pathway_path, notice: "Se creó exitosamente la imagen #{@routecover.name}"
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @routecover.update(cover_params)
      redirect_to dashboard_pathway_path(@routecover), notice: "Se actualizó exitosamente la pregunta #{@routecover.name}"
	else
	  render :edit
	end	
  end

  def destroy
  	@routecover.destroy
	redirect_to dashboard_pathway_path, notice: "Se eliminó exitosamente la portada #{@routecover.name}"
  end

  private
  def cover_params
	params.require(:route_cover).permit(:name, :route_image)
  end

  def set_cover
	@routecover = RouteCover.find(params[:id])
  end

end
