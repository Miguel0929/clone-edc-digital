class DiagnosticTestMailer

	FROM = "soporte@edc-digital.com"
  NAME = "EDC Digital"

	def self.send_results(user, 
                        question_0, answer_0, message_0,
                        question_1, answer_1, message_1,
                        question_2, answer_2, message_2,
                        question_3, answer_3, message_3,
                        question_4, answer_4, message_4,
                        question_5, answer_5, message_5,
                        question_6, answer_6, message_6,
                        question_7, answer_7, message_7,
                        question_8, answer_8, message_8
                        )

		 data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-user_name-" => user.name,
              "-question_0-" => question_0,
              "-answer_0-" => answer_0,
              "-message_0-" => message_0,
              "-question_1-" => question_1,
              "-answer_1-" => answer_1,
              "-message_1-" => message_1,
              "-question_2-" => question_2,
              "-answer_2-" => answer_2,
              "-message_2-" => message_2,
              "-question_3-" => question_3,
              "-answer_3-" => answer_3,
              "-message_3-" => message_3,
              "-question_4-" => question_4,
              "-answer_4-" => answer_4,
              "-message_4-" => message_4,
              "-question_5-" => question_5,
              "-answer_5-" => answer_5,
              "-message_5-" => message_5,
              "-question_6-" => question_6,
              "-answer_6-" => answer_6,
              "-message_6-" => message_6,
              "-question_7-" => question_7,
              "-answer_7-" => answer_7,
              "-message_7-" => message_7,
              "-question_8-" => question_8,
              "-answer_8-" => answer_8,
              "-message_8-" => message_8
            },
            subject: "Diagnóstico del curso de Bienvenida"
          },
        ],
        from: {
          email: FROM,
          name: NAME
        },
        template_id: "2173bac0-9b93-4cbe-b4f9-270ccc148627",
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