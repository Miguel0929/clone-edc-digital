class WelcomeAfterInvitation

	FROM = "soporte2@edc-digital.com"
  NAME = "EDC Digital"

	def self.send_welcome_message(user, chosen_subject, root_link, route_link, more_link, privacy_link, faqs_link, variable_text, mailer_template)

		 data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-user_name-" => user.name,
              "-log_in_link-" => root_link,
              "-edc_route_link-" => route_link,
              "-edc_more_link-" => more_link,
              "-edc_privacy_link-" => privacy_link,
              "-edc_faqs_link-" => faqs_link,
              "-variable_text-" => variable_text
            },
            subject: chosen_subject
          },
        ],
        from: {
          email: FROM,
          name: NAME
        },
        template_id: mailer_template,
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