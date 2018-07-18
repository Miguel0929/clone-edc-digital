class WelcomeAfterInvitation

	FROM = "soporte@edc-digital.com"
  NAME = "EDC Digital"

	def self.send_welcome_message(user)
    puts "ay wey, dentro del mailer"
		 data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-user_name-" => user.name
            },
            subject: user.student? ? "¡Bienvenidos, alumnos!" : "¡Bienvenidos, profesores!"
          },
        ],
        from: {
          email: FROM,
          name: NAME
        },
        template_id: "41b96136-9eb4-4943-9a39-455dbfd3e1cc",
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