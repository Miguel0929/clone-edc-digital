class Dashboard::TemplateRefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  include ActiveElementsHelper
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    if current_user.student?
      @this_user = current_user
      add_breadcrumb "<a href='#{dashboard_template_refilables_path}' class='active'>Mis plantillas</a>".html_safe 
      @template_refilables = get_active_elements(current_user, "template_refilables")
    else
      @student = User.find(params[:user_id])
      @this_user = @student
      add_breadcrumb "Estudiantes", :mentor_students_path
      add_breadcrumb "<a href='#{mentor_student_path(@student)}'>#{@student.email}</a>".html_safe
      add_breadcrumb "<a class='active' href='#{dashboard_template_refilables_path(user_id: @student.id)}'>Plantillas</a>".html_safe
      @template_refilables = @this_user.group.all_refilables
    end
    puts @template_refilables.class
    puts "no mamar"
    if !params[:program_id].nil?
      @template_refilables.select {|x| x['program_id'] == params[:program_id] }
      @program = Program.find(params[:program_id])
    end

    @done_refilables = []
    @undone_refilables = []
    @template_refilables.each do |refil|
    	if refil.refilables.find_by(user: @this_user)
    		@done_refilables.push(refil)
    	else
    		@undone_refilables.push(refil)
    	end
    end
  end
end
