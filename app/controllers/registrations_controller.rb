class RegistrationsController < Devise::RegistrationsController

	def new
		super
	end

	def create
		super
	end

	def update
		old_ind = current_user.industry_id
		super do
			@new_ind = resource.industry_id
		end

		if old_ind != @new_ind
			if old_ind.nil? then old_ind = "Ninguna" end
			if @new_ind.nil? then @new_ind = "Ninguna" end

			data = {
					personalizations: [
						{
							to: [ { email: "soporte@edc-digital.com" } ],
							substitutions: {
								"-user_name-" => current_user.name,
								"-user_email-" => current_user.email,
								"-old_industry-" => old_ind,
								"-new_industry-" => @new_ind
							},
							subject: "Un usuario ha cambiado de industria"
						},
					],
					from: {
						email: "soporte@edc-digital.com"
					},
					template_id: "21767291-6af7-411f-8032-fa8d201cc989"
			}

			sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
			begin
				response = sg.client.mail._("send").post(request_body: data)
				Rails.logger.info response.status_code
				Rails.logger.info response.body
				Rails.logger.info response.headers
				FakeEmail.new
			rescue Exception => e
				Rails.logger.info e.message
				FakeEmail.new
			end
		end
	end

end 