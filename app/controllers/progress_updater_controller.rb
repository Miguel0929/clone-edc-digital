class ProgressUpdaterController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_mentor

  add_breadcrumb "EDC DIGITAL", :root_path

  def show
  	add_breadcrumb "<a href='#{progress_panel_index_path}'>Panel de progreso</a>".html_safe
  	add_breadcrumb "<a class='active' href='#'>Actualización de progreso de estudiantes</a>".html_safe
    @job_id = params[:id]
  end
end