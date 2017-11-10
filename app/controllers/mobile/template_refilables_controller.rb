class Mobile::TemplateRefilablesController < Mobile::BaseController
  #before_action :authorize

  def index
    refilables = TemplateRefilable.joins(:groups)
                                    .where('groups.id = ?', current_user.group.id)
                                    .order(position: :asc)
    done_refilables = []
    undone_refilables = []
    refilables.each do |refil|
    	if refil.refilables.find_by(user: current_user)
    		done_refilables.push(refil)
    	else
    		undone_refilables.push(refil)
    	end
    end

    render json: { done_refilables: done_refilables, undone_refilables: undone_refilables}
  end
end
