class DelireverablePackagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delireverable_package, only: [:edit, :update, :destroy]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{delireverable_packages_path}'>Paquetes de entregables</a>".html_safe

    @delireverable_packages =  DelireverablePackage.all.includes(:groups)
  end

  def new
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb "<a class='active' href='#{new_delireverable_package_path}'>Nuevo paquete</a>".html_safe

    @delireverable_package = DelireverablePackage.new
  end

  def create
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb "<a class='active' href='#{new_delireverable_package_path}'>Nuevo paquete</a>".html_safe

    @delireverable_package = DelireverablePackage.new(delireverable_package_params)

    if @delireverable_package.save
      redirect_to delireverable_packages_path, notice: 'Paquete creado'
    else
      render :new
    end
  end

  def edit
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb "<a class='active' href='#{edit_delireverable_package_path(@delireverable_package)}'>#{@delireverable_package.name}</a>".html_safe
  end

  def update
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb "<a class='active' href='#{edit_delireverable_package_path(@delireverable_package)}'>#{@delireverable_package.name}</a>".html_safe
    
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
    params.require(:delireverable_package).permit(:name, :description, :tipo, group_ids: [])
  end

  def set_delireverable_package
    @delireverable_package = DelireverablePackage.find(params[:id])
  end
end
