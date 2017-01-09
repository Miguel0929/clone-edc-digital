class DeletedUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:update]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{deleted_users_path}'>Usuarios desactivados</a>".html_safe

    @users = User.includes(:group).only_deleted
  end

  def update
    @user.restore

    redirect_to deleted_users_path
  end

  private
  def set_user
    @user = User.only_deleted.find(params[:id])
  end
end
