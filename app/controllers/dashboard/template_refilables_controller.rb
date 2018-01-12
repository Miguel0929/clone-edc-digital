class Dashboard::TemplateRefilablesController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_template_refilables_path}' class='active'>Mis plantillas</a>".html_safe                            
    
    @refilables = current_user.group.all_refilables
    
    @done_refilables = []
    @undone_refilables = []
    @refilables.each do |refil|
    	if refil.refilables.find_by(user: current_user)
    		@done_refilables.push(refil)
    	else
    		@undone_refilables.push(refil)
    	end
    end
  end
end
