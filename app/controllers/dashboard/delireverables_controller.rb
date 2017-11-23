class Dashboard::DelireverablesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_delireverables_path}' class='active'>Mis entregables</a>".html_safe

    delireverables_groups = Delireverable.joins(delireverable_package: [:groups])
                                   .where('groups.id = ?', current_user.group.id)
                                   .order(position: :asc).pluck(:id)

    packages = current_user.group.learning_path.learning_path_contents.where(content_type: "DelireverablePackage")
    ids=[]
    packages.each do |package|
      package.model.delireverables.each do |delireverable|
        ids << delireverable.id
      end  
    end                                                               
    aux=ids.concat(delireverables_groups)                               
    @delireverables=Delireverable.where(id: aux)

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
