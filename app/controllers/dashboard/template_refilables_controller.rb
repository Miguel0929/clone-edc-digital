class Dashboard::TemplateRefilablesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_template_refilables_path}' class='active'>Mis rellenables</a>".html_safe
    refilables_groups = TemplateRefilable.joins(:groups)
                                    .where('groups.id = ?', current_user.group.id)
                                    .order(position: :asc).pluck(:id)
    refilables_fisica = current_user.group.learning_path.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
    refilables_moral = current_user.group.learning_path2.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)                                    

    aux = refilables_fisica + refilables_moral + refilables_groups                              
    
    @refilables=TemplateRefilable.where(id: aux)
    
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
