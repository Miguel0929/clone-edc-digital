class VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    add_breadcrumb "EDC DIGITAL", :root_path
    add_breadcrumb "<a class='active' href='#{visits_path}'>Visitas</a>".html_safe

    @visits = Visit.includes(:user).where.not(user: nil).page(params[:page]).per(50)
  end
end
