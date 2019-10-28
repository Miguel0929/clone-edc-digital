class Support
  require 'sendgrid-ruby'
  include SendGrid
  require 'json'
  extend MailTemplateHelper

  FROM = mailer_from_helper('')
  NAME = company_name_helper('')

  def self.contact(subject, message, urgency, matter, user, chapter, signature, recipient, program, chaptercontent, attachment)
    require "base64"

    if attachment.nil?  
      template_title = "Solicitud de soporte de plataforma"
      template_name = "Hola administrador"
      template_message = "El usuario " + user.name + " (email: " + user.email + ", teléfono: " + user.phone_number + ") solicita soporte.</p><strong>Nivel de urgencia: </strong>" + urgency + "<br><strong>Clasificación del mensaje: </strong>" + matter + "<br><strong>Programa seleccionado: </strong>" + program + "<br><strong>Último contenido visitado: </strong>" + chaptercontent + "<br><br><h4 style='margin-bottom:15px;'>Mensaje:</h4><p style='margin-bottom:35px;'>" + message
      template_footer = company_name_helper('Nuestro equipo')
      mail_recipient = mailer_support_helper
      mail_subject = subject

      send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
    else
      template_title = "Solicitud de soporte de plataforma"
      template_name = "Hola administrador"
      template_message = "El usuario " + user.name + " (email: " + user.email + ", teléfono: " + user.phone_number + ") solicita soporte.</p><strong>Nivel de urgencia: </strong>" + urgency + "<br><strong>Clasificación del mensaje: </strong>" + matter + "<br><strong>Programa seleccionado: </strong>" + program + "<br><strong>Último contenido visitado: </strong>" + chaptercontent + "<br><br><h4 style='margin-bottom:15px;'>Mensaje:</h4><p style='margin-bottom:35px;'>" + message + "</p><p>[Este mensaje contiene un archivo adjunto]"
      template_footer = company_name_helper('Nuestro equipo')
      mail_recipient = mailer_support_helper
      mail_subject = subject
      basecode = Base64.strict_encode64(File.read(attachment.tempfile))

      Support.send_mail_template_attachment(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject, basecode, attachment.original_filename, attachment.content_type)
    end
  end

  def self.notify(subject, raw_subject, message, urgency, matter, user, chapter, signature, recipient,attachment)
    require "base64"

    if attachment.nil?
      template_title = "¡Hemos recibido tu solicitud de ayuda!"
      template_name = (user.first_name.nil? ? "Hola" : user.name)
      template_message = "Recibimos tu mensaje: <em>" + raw_subject + "</em>. Estamos por atenderlo. Te pedimos te mantengas al tanto de tu correo y de la plataforma para tener retroalimentación cuanto antes.</p>" +
                         "<p>Nuestros mentores y expertos pueden demorar un poco para responder cada caso, por lo que te pedimos ser paciente :) </p> <p>Estamos para servirte, que tengas un excelente día."
      template_footer = company_name_helper('Nuestro equipo')
      mail_recipient = recipient
      mail_subject = subject

      send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
    else 
      template_title = "¡Hemos recibido tu solicitud de ayuda!"
      template_name = (user.first_name.nil? ? "Hola" : user.name)
      template_message = "Recibimos tu mensaje: <em>" + raw_subject + "</em>. Estamos por atenderlo. Te pedimos te mantengas al tanto de tu correo y de la plataforma para tener retroalimentación cuanto antes.</p>" +
                         "<p>Nuestros mentores y expertos pueden demorar un poco para responder cada caso, por lo que te pedimos ser paciente :) </p> <p>Estamos para servirte, que tengas un excelente día.</p> <p>[Este mensaje contiene un archivo adjunto]"
      template_footer = company_name_helper('Nuestro equipo')
      mail_recipient = recipient
      mail_subject = subject
      basecode = Base64.strict_encode64(File.read(attachment.tempfile))

      Support.send_mail_template_attachment(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject, basecode, attachment.original_filename, attachment.content_type)
    end  
  end

  def self.sin_grupo(user, state, university, url, group)
    template_title = "Estudiante sin grupo"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    greetings = (user.first_name.nil? ? "" : user.name)
    template_message = "El usuario " + greetings + " (email: " + user.email + ") no tiene un grupo. Se le ha asignado un grupo temporal.<br><br><strong>Estado: </strong>" + state.name + "<br><strong>Universidad: </strong>" + (university.empty? ? "sin universidad" : university) + "<br><strong>Grupo: </strong>" + group.name + "<br><strong>Perfil del usuario: </strong><a href='" + url + "'>" + url + "</a>"
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = mailer_support_helper
    mail_subject = "El estudiante " + (user.first_name.nil? ? user.email : user.name) + " no tiene grupo asignado"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.send_mail_template_attachment(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject, attachment_content, attachment_filename, attachment_type)

    company_name = company_name_helper('')
    company_mail = mailer_from_helper('')
    company_address = company_address_helper('')
    company_link = company_link_helper('')
    mail_message = IO.read(Rails.root + "app/views/generic_mailer_template/mail_template.txt") #Template tomado de aquí: https://github.com/derekpunsalan/responsive-email/blob/master/simple.html
    replacements = [["-template_title-", template_title], ["-template_name-", (template_name.empty? ? "Hola" : template_name)], 
                    ["-template_message-", template_message], 
                    ["-template_footer-", template_footer], ["-template_company_link-", company_link], ["-template_company_name-", company_name], 
                    ["-template_company_address-", company_address], ["-template_company_mail-", company_mail]]
    replacements.each {|replacement| mail_message.gsub!(replacement[0], replacement[1])}

    #Tomado del ejemplo completo que aparece aquí:
    #https://github.com/sendgrid/sendgrid-ruby/blob/master/examples/mail/mail.rb#L26

    string1 = 
      '{
        "content": [
        {
          "type": "text/html", 
          "value":
      '
    string2 = mail_message
    string3 = 
      '
        }
        ], 
        "from": {
        "email":
      '
    string4 = '"' + company_mail + '",'
    string5 =
      '
        "name":
      '
    string6 = '"' + company_name + '"'
    string7 =
      '
        }, 
        "headers": {}, 
        "mail_settings": {
        "bypass_list_management": {
          "enable": true
        },
        "sandbox_mode": {
          "enable": false
        }, 
        "spam_check": {
          "enable": true, 
          "post_to_url": "http://example.com/compliance", 
          "threshold": 3
        }
        }, 
        "personalizations": [
        {
          "headers": {
          "X-Accept-Language": "es", 
          "X-Mailer": "MyApp"
          }, 
          "subject": 
      '
    string8 = '"' + mail_subject + '",'
    string9 =
      '
          "to": [
          {
            "email": 
      '
    string10 = '"' + mail_recipient + '"'
    string11 = 
      '
          }
          ]
        }
        ], 
        "subject":
      '
    string12 = '"' + mail_subject + '",'
    string13 = 
      '
        "attachments": [
        {
          "content": 
      '
    string14 = '"' + attachment_content + '",'
    string15 = 
      '
          "filename": 
      '
    string16 = '"' + attachment_filename + '",'
    string17 =
      '
          "type": 
      '
    string18 = '"' + attachment_type + '"'
    string19 =
      '
        }
        ]
      '
    string20 =
      '
      }'

    data = JSON.parse(string1 + string2 + string3 + string4 + string5 + string6 + string7 + string8 + string9 + string10 + string11 + string12 + string13 + string14 + string15 + string16 + string17 + string18 + string19 + string20)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')
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
