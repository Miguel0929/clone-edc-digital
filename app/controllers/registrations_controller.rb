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

		# Se pidió que se eliminara la siguiente notificación por correo de cambio de industria

		#old_ind = current_user.industry_id

		#if old_ind != @new_ind

		#	if old_ind.nil? 
		#		old_ind = "Ninguna"
		#	else
		#		old_ind = Industry.find(old_ind).name
		#	end
		#	if @new_ind.nil? 
		#		@new_ind = "Ninguna" 
		#	else
		#		@new_ind = Industry.find(@new_ind).name
		#	end
			
		#	#Esto siguiente fue obtenido de users/invitations_controller.rb
		#	data = {
		#			personalizations: [
		#				{
		#					to: [ { email: "soporte@edc-digital.com" } ],
		#					substitutions: {
		#						"-user_name-" => current_user.name,
		#						"-user_email-" => current_user.email,
		#						"-old_industry-" => old_ind,
		#						"-new_industry-" => @new_ind
		#					},
		#					subject: "Un usuario ha cambiado de industria"
		#				},
		#			],
		#			from: {
		#				email: "soporte-edcdigital@distritoemprendedor.com"
		#			},
		#			template_id: "21767291-6af7-411f-8032-fa8d201cc989"
		#	}
		#
		#	sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
		#	begin
		#		response = sg.client.mail._("send").post(request_body: data)
		#		Rails.logger.info response.status_code
		#		Rails.logger.info response.body
		#		Rails.logger.info response.headers
		#		FakeEmail.new
		#	rescue Exception => e
		#		Rails.logger.info e.message
		#		FakeEmail.new
		#	end
		#end
	end

	protected
	def after_update_path_for(resource)
    	edit_user_registration_path
  	end

end 