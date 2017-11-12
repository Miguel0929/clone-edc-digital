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

  def router
    template = TemplateRefilable.find(params[:id])
    refil = template.refilables.find_by(user: current_user)

    if refil.nil?
      redirect_to new_mobile_template_refilable_refilable_path(template, user_token: params[:user_token], user_email: params[:user_email])
    else
      redirect_to edit_mobile_template_refilable_refilable_path(template, refil, user_token: params[:user_token], user_email: params[:user_email])
    end
  end
end
