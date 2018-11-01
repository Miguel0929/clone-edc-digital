class RegistrationsController < Devise::RegistrationsController

	def new
		super
	end

	def create
		super
	end

	def update
		super do
			@new_ind = resource.industry_id

			if Date.valid_date?(params[:user_detail]['birthdate(1i)'.to_sym].to_i, params[:user_detail]['birthdate(2i)'.to_sym].to_i, params[:user_detail]['birthdate(3i)'.to_sym].to_i)
				old_birthdate = (params[:user_detail]['birthdate(3i)'.to_sym] + "/" + params[:user_detail]['birthdate(2i)'.to_sym] + "/" + params[:user_detail]['birthdate(1i)'.to_sym]).to_date
			else
				old_birthdate = nil
			end
			old_situation = params[:user][:situation]
			old_interest = params[:user][:interest]
			old_challenge = params[:user][:challenge]
			old_goal = params[:user][:goal]

			if current_user.user_detail.nil?
				current_user.create_user_detail(birthdate: old_birthdate, situation: old_situation, interest: old_interest, challenge: old_challenge, goal: old_goal)
			else
				current_user.user_detail.update(birthdate: old_birthdate, situation: old_situation, interest: old_interest, challenge: old_challenge, goal: old_goal)
			end
		end
	end

	protected
	def after_update_path_for(resource)
    	edit_user_registration_path
  	end

end 