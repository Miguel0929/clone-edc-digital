class VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    add_breadcrumb "Administrador", :root_path
    add_breadcrumb "<a class='active' href='#{visits_path}'>Visitas</a>".html_safe

    @visits = Visit.where.not(user: nil)
  end
end
