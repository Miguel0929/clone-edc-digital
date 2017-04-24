class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_when_is_not_student
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_programs_path}'>Programas</a>".html_safe
    @programs = current_user.group.programs.order(position: :asc) rescue []
  end

  def show
    @program = Program.find(params[:id])

    add_breadcrumb "Programas", :dashboard_programs_path
    add_breadcrumb "<a class='active' href='#{dashboard_program_path @program}'>#{@program.name}</a>".html_safe
    respond_to do |format|
      format.html
      format.xlsx{response.headers['Content-Disposition']='attachment; filename="mis_respuestas_#{@program.name}.xlsx"'}
    end
  end

  def resume
    @program = Program.find(params[:id])
    add_breadcrumb "programas", :dashboard_programs_path
    add_breadcrumb @program.name, dashboard_program_path(@program)
    add_breadcrumb "<a class='active' href='#{resume_dashboard_program_path @program}'>Rúbrica de evaluación</a>".html_safe
  end

  private
  def redirect_when_is_not_student
    if current_user.admin?
      redirect_to students_users_path
    elsif current_user.mentor?
      redirect_to mentor_groups_path
    end
  end
end
