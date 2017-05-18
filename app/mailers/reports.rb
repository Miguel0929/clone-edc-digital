class Reports
	FROM = "soporte-edcdigital@distritoemprendedor.com"
	
	def self.report(report)
		data = {
      personalizations: [
        {
          to: [ { email: "soporte@edc-digital.com" } ],
          substitutions: {
            "-raw_subject-"=> "EDC-Digital: Contenido Reportado ID: #{report.id.to_s}",
            "-cause-" => report.cause.to_s,
            "-content_reported-" => report.reportable_id.to_s,
            "-email-" => report.user.email,
            "-user_name-" => report.user.name,
            "-id-" => report.user.id.to_s,
            "-program-" => report.model.chapter.program.name,
            "-chapter-" => report.model.chapter.name,
            "-content-" => report.model.model.identifier,
          },
          subject: "EDC-Digital: Contenido Reportado ID: #{report.id.to_s}"
        },
      ],
      from: {
        email: FROM
      },
      reply_to: {
          email: report.user.email, 
          name: report.user.name
        },
      template_id: "6aa47aef-e064-46c2-9a50-cc744517c7c9",
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