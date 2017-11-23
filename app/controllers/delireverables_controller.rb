class DelireverablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delireverable_package
  before_action :set_delireverable, only: [:edit, :update, :destroy]
  before_action :require_admin
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "Paquetes de entregables", :delireverable_packages_path
    add_breadcrumb "<a class='active' href='#{delireverable_package_delireverables_path(@delireverable_package)}'>#{@delireverable_package.name}</a>".html_safe

    #@delireverables =  Delireverable.all
    @delireverables =  @delireverable_package.delireverables
  end

  def new
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb @delireverable_package.name, delireverable_package_delireverables_path(@delireverable_package)
    add_breadcrumb "<a class='active' href='#{new_delireverable_package_delireverable_path(@delireverable_package)}'>Nuevo entregable</a>".html_safe

    @delireverable = @delireverable_package.delireverables.new
  end

  def create
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb @delireverable_package.name, delireverable_package_delireverables_path(@delireverable_package)
    add_breadcrumb "<a class='active' href='#{new_delireverable_package_delireverable_path(@delireverable_package)}'>Nuevo entregable</a>".html_safe

    @delireverable = @delireverable_package.delireverables.new(delireverable_params)

    if @delireverable.save
      redirect_to delireverable_package_delireverables_path(@delireverable_package), notice: 'Entregable creado'
    else
      render :new
    end
  end

  def edit
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb @delireverable_package.name, delireverable_package_delireverables_path(@delireverable_package)
    add_breadcrumb "<a class='active' href='#{edit_delireverable_package_delireverable_path(@delireverable_package, @delireverable)}'>Editar entregable</a>".html_safe
  end

  def update
    add_breadcrumb "Paquete de entregables", :delireverable_packages_path
    add_breadcrumb "<a class='active' href='#{edit_delireverable_package_path(@delireverable_package)}'>#{@delireverable_package.name}</a>".html_safe

    if @delireverable.update(delireverable_params)
      redirect_to delireverable_package_delireverables_path(@delireverable_package), notice: 'Entregable actualizado'
    else
      render :new
    end
  end

  def destroy
    @delireverable.destroy

    redirect_to delireverable_package_delireverables_path(@delireverable_package), notice: 'Entregable eliminado'
  end

  def sort
    params[:delireverable].each_with_index do |id, index|
      Delireverable.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
  end

  private
  def delireverable_params
    params.require(:delireverable).permit(:name, :description, :file)
  end

  def set_delireverable_package
    @delireverable_package = DelireverablePackage.find(params[:delireverable_package_id])
  end

  def set_delireverable
    @delireverable = Delireverable.find(params[:id])
  end
end
