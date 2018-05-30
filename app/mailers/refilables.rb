class Refilables
	FROM = "soporte@edc-digital.com"
  NAME = "EDC Digital"
	def self.up_rubric(template, user, ruta)
		data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Se ha actualizado tu rúbrica de evaluación en EDC Digital",
            "-content-" => "Tu rúbrica de evaluación en la plantilla \"#{template.name}\" ha sido actualizada recientemente",
            "-url-" => ruta,
          },
          subject: "Se ha actualizado tu rúbrica de evaluación en EDC Digital"
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
	def self.commented(template, user, ruta)
		data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Tus respuestas a una plantilla han sido comentadas en EDC Digital",
            "-content-" => "Tus respuestas a la plantilla \"#{template.name}\" han sido comentadas por un mentor",
            "-url-" => ruta,
          },
          subject: "Tus respuestas a una plantilla han sido comentadas en EDC Digital"
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