class Programs
	FROM = "soporte@edc-digital.com"
	def self.new_program(program, user, ruta)
  	  data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-raw_subject-"=> "Un nuevo programa ha sido añadido para ti en EDCdigital",
              "-content-" => "El programa \"#{program.name}\" ahora esta diponible para ti en EDCdigital",
              "-url-" => ruta,
            },
            subject: "El nuevo programa ha sido añadido para ti en EDCdigital"
          },
        ],
        from: {
          email: FROM
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

	def self.up_program(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: "donpancholin50@hotmail.com" } ],
          substitutions: {
            "-raw_subject-" => "Se ha actualizado tu curso \"#{program.name}\" en EDCdigital",
            "-content-" => "El programa \"#{program.name}\" tiene nuevo contenido diponible para ti en EDCdigital",
            "-url-" => ruta,
          },
          subject: "Se ha actualizado tu curso \"#{program.name}\" en EDCdigital"
        },
      ],
      from: {
        email: FROM
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
  def self.up_rubric(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: "donpancholin50@hotmail.com" } ],
          substitutions: {
            "-raw_subject-" => "Se ha actualizado tu rúbrica de evaluación en EDCdigital",
            "-content-" => "Tu rúbrica de evaluación en el programa \"#{program.name}\" ha sido actualizada recientemente",
            "-url-" => ruta,
          },
          subject: "Se ha actualizado tu rúbrica de evaluación en EDCdigital"
        },
      ],
      from: {
        email: FROM
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
  def self.up_evaluation(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: "donpancholin50@hotmail.com" } ],
          substitutions: {
            "-raw_subject-" => "Has sido evaluado en el programa \"#{program.name}\"",
            "-content-" => "Has sido evaluado en el programa \"#{program.name}\" en EDCdigital",
            "-url-" => ruta,
          },
          subject: "Has sido evaluado en el programa \"#{program.name}\""
        },
      ],
      from: {
        email: FROM
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