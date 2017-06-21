class Dashboard::UsersController < ApplicationController
  before_action :authenticate_user!

  add_breadcrumb "EDCDIGITAL", :root_path

  def show
    @user = User.find(params[:id])
    add_breadcrumb "<a class='active' href='#{dashboard_user_path(@user)}'>Información de perfil</a>".html_safe
  end
end
