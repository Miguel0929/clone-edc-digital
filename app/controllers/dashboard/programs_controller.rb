class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_programs_path}'>Programas</a>".html_safe
    @programs = current_user.group.programs
  end

  def show
    @program = Program.find(params[:id])

    add_breadcrumb "programas", :dashboard_programs_path
    add_breadcrumb "<a class='active' href='#{dashboard_program_path @program}'>#{@program.name}</a>".html_safe
  end

  def resume
    @program = Program.find(params[:id])
    add_breadcrumb "programas", :dashboard_programs_path
    add_breadcrumb "<a href='#{dashboard_program_path @program}'>#{@program.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{resume_dashboard_program_path @program}'>Rúbrica de evaluación</a>".html_safe
  end
end
