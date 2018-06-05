class Programs
	FROM = "soporte@edc-digital.com"
  NAME = "EDC Digital"
	def self.new_program(program, user, ruta)
  	  data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-raw_subject-"=> "Un nuevo programa ha sido añadido para ti en EDC Digital",
              "-content-" => "El programa \"#{program.name}\" ahora esta diponible para ti en EDC Digital",
              "-url-" => ruta,
            },
            subject: "El nuevo programa ha sido añadido para ti en EDC Digital"
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

	def self.up_program(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Se ha actualizado tu curso \"#{program.name}\" en EDC Digital",
            "-content-" => "El programa \"#{program.name}\" tiene nuevo contenido diponible para ti en EDC Digital",
            "-url-" => ruta,
          },
          subject: "Se ha actualizado tu curso \"#{program.name}\" en EDC Digital"
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
  def self.up_rubric(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Se ha actualizado tu rúbrica de evaluación en EDC Digital",
            "-content-" => "Tu rúbrica de evaluación en el programa \"#{program.name}\" ha sido actualizada recientemente",
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
  def self.up_evaluation(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Has sido evaluado en el programa \"#{program.name}\"",
            "-content-" => "Has sido evaluado en el programa \"#{program.name}\" en EDC Digital",
            "-url-" => ruta,
          },
          subject: "Has sido evaluado en el programa \"#{program.name}\""
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
  def self.more95_mentor(program, user, student, ruta)
    data = {
      personalizations: [
        {
          to: [ { email:  user.email } ],
          substitutions: {
            "-raw_subject-" => "El Alumno #{student.name} está a punto de terminar el programa #{program.name}.",
            "-content-" => "El Alumno #{student.name} está a punto de concluir el programa #{program.name}, te invitamos a que revises sus avances y completes la rúbrica de evaluación correspondiente.",
            "-url-" => ruta,
          },
          subject: "El Alumno #{student.name} está a punto de terminar el programa #{program.name}."
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
  def self.more95_student(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Estas a punto de terminar el programa \"#{program.name}\".",
            "-content-" => "Estas a punto de terminar el programa \"#{program.name}\" en EDCdigital.",
            "-url-" => ruta,
          },
          subject: "Estas a punto de terminar el programa \"#{program.name}\"."
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
  def self.complete_mentor(program, user, student, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "El alumno #{student.name} ha terminado el programa \"#{program.name}\".",
            "-content-" => "El alumno #{student.name} ha terminado el programa \"#{program.name}\", te invitamos a que revises sus avances y completes la rúbrica de evaluación correspondiente.",
            "-url-" => ruta,
          },
          subject: "El alumno #{student.name} ha terminado el programa \"#{program.name}\"."
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
  def self.complete_student(program, user, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: user.email } ],
          substitutions: {
            "-raw_subject-" => "Has terminado el programa \"#{program.name}\".",
            "-content-" => "Has terminado el programa \"#{program.name}\" en EDCdigital.",
            "-url-" => ruta,
          },
          subject: "Has terminado el programa \"#{program.name}\"."
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
  def self.key_question(program, user, student, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: "donpancholin50@hotmail.com" } ],
          substitutions: {
            "-raw_subject-" => "El alumno #{student.name} ha contestado una pregunta clave del programa \"#{program.name}\".",
            "-content-" => "El alumno #{student.name} ha contestado una pregunta clave del programa \"#{program.name}\", te invitamos a que revises sus avances así como la rúbrica de evaluación correspondiente.",
            "-url-" => ruta,
          },
          subject: "El alumno #{student.name} ha contestado una pregunta clave del programa \"#{program.name}\"."
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
  def self.answered_refilable(program, template_refilable, soporte2, student, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: soporte2 } ],
          substitutions: {
            "-raw_subject-" => "El alumno #{student.name} ha contestado la plantilla \"#{template_refilable.name}\".",
            "-content-" => "El alumno #{student.name} ha contestado la plantilla \"#{template_refilable.name}\" del programa \"#{program.nil? ? 'Plantilla sin programa' : program.name}\", te invitamos a que revises sus avances.",
            "-url-" => ruta,
          },
          subject: "El alumno #{student.name} ha contestado la plantilla \"#{template_refilable.name}\"."
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

  def self.update_question(chapter_content, mentor, student, ruta)
    data = {
      personalizations: [
        {
          to: [ { email: "donpancholin50@hotmail.com" } ],
          substitutions: {
            "-raw_subject-" => "El estudiante \"#{student.name}\" ha corregido un respuesta EDC Digital",
            "-content-" => "El estudiante \"#{student.name}\" ha corregido un respuesta EDC Digital, ve al enlace para evaluar su nueva respuesta",
            "-url-" => ruta,
          },
          subject: "El estudiante \"#{student.name}\" ha corregido un respuesta EDC Digital"
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