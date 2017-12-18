class Dashboard::DelireverablesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_delireverables_path}' class='active'>Mis entregables</a>".html_safe

    
    @delireverables= current_user.group.all_delireverables
    
    @done_delireverables = []
    @undone_delireverables = []    
    @delireverables.each do |deliv|
    	if deliv.delireverable_users.find_by(user: current_user)
    		@done_delireverables.push(deliv)
    	else
    		@undone_delireverables.push(deliv)
    	end
    end                               
  end
end
