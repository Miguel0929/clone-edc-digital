class DelireverablePackagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delireverable_package, only: [:edit, :update, :destroy]

  def index
    @delireverable_packages =  DelireverablePackage.all.includes(:groups)
  end

  def new
    @delireverable_package = DelireverablePackage.new
  end

  def create
    @delireverable_package = DelireverablePackage.new(delireverable_package_params)

    if @delireverable_package.save
      redirect_to delireverable_packages_path, notice: 'Paquete creado'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @delireverable_package.update(delireverable_package_params)
      redirect_to delireverable_packages_path, notice: 'Paquete actualizado'
    else
      render :new
    end
  end

  def destroy
    @delireverable_package.destroy

    redirect_to delireverable_packages_path, notice: 'Paquete eliminado'
  end

  private
  def delireverable_package_params
    params.require(:delireverable_package).permit(:name, :description, group_ids: [])
  end

  def set_delireverable_package
    @delireverable_package = DelireverablePackage.find(params[:id])
  end
end
