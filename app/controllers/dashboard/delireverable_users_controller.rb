class Dashboard::DelireverableUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delireverable
  add_breadcrumb "EDCDIGITAL", :root_path

  def new
    add_breadcrumb "Entregables", :dashboard_delireverables_path
    add_breadcrumb "<a href='#{new_dashboard_delireverable_delireverable_user_path(@delireverable)}' class='active'>Subir entregable</a>".html_safe

    if delireverable = @delireverable.delireverable_users.find_by(user: current_user)
      @delireverable_user = delireverable
    else
      @delireverable_user = @delireverable.delireverable_users.new
    end
  end

  def create
    add_breadcrumb "Entregables", :dashboard_delireverables_path
    add_breadcrumb "<a href='#{new_dashboard_delireverable_delireverable_user_path(@delireverable)}' class='active'>Subir entregable</a>".html_safe

    if delireverable = @delireverable.delireverable_users.find_by(user: current_user)
      @delireverable_user = delireverable
      @delireverable_user.file = delireverable_user_params[:file]
    else
      @delireverable_user = @delireverable.delireverable_users.new(delireverable_user_params)
    end

    @delireverable_user.user = current_user

    if @delireverable_user.save
      redirect_to dashboard_delireverables_path, notice: 'Has subido un entregable'
    else
      render :new
    end
  end

  private
  def set_delireverable
    @delireverable = Delireverable.find(params[:delireverable_id])
  end

  def delireverable_user_params
    params.require(:delireverable_user).permit(:file)
  end
end
