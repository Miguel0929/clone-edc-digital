class Dashboard::DelireverablesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_delireverables_path}' class='active'>Mis entregables</a>".html_safe

    delireverables_groups = Delireverable.joins(delireverable_package: [:groups])
                                   .where('groups.id = ?', current_user.group.id)
                                   .order(position: :asc).pluck(:id)

    fisica_packages = current_user.group.learning_path.learning_path_contents.where(content_type: "DelireverablePackage")
    moral_packages = current_user.group.learning_path2.learning_path_contents.where(content_type: "DelireverablePackage")
    
    ids_fisica=[]
    fisica_packages.each do |package|
      package.model.delireverables.each do |delireverable|
        ids_fisica << delireverable.id
      end  
    end

    ids_moral=[]
    moral_packages.each do |package|
      package.model.delireverables.each do |delireverable|
        ids_moral << delireverable.id
      end  
    end                              
    
    aux = ids_fisica + ids_moral + delireverables_groups
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
