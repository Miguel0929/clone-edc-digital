class LearningPathMailer
	FROM = "soporte@edc-digital.com"
  NAME = "EDC Digital"
	def self.up_learning_path(user, ruta)
		 data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-raw_subject-"=> "Tu ruta de aprendizaje ha sido actualizada en EDC Digital",
              "-content-" => "Tu ruta de aprendizaje ha sido actualizada en EDC Digital",
              "-url-" => ruta,
            },
            subject: "Tu ruta de aprendizaje ha sido actualizada en EDC Digital"
          },
        ],
        from: {
          email: FROM,
          name: NAME
        },
        template_id: "0a672cf0-6306-443b-9508-845a0599c9ea",
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