class Support

  FROM = "soporte-edcdigital@distritoemprendedor.com"

  def self.contact(subject, message, urgency, matter, user, chapter, signature, recipient, program, chaptercontent, attachment)
    require "base64"
    if attachment.nil?  
      data = {
        personalizations: [
          {
            to: [ { email: recipient } ],
            substitutions: {
              "-raw_subject-"=> subject,
              "-user_name-" => user.name,
              "-user_email-" => user.email,
              "-user_phone_number-" => user.phone_number,
              "-urgency-" => urgency,
              "-matter-" => matter,
              "-message-" => message,
              "-program-" => program,
              "-last_content-" => chaptercontent
            },
            subject: subject
          },
        ],
        from: {
          email: FROM
        },
        reply_to: {
          email: user.email, 
          name: user.name
        },
        template_id: "4969519e-b843-431d-8ccd-93123332ab0c"
      }
    else
     data = {
        personalizations: [
          {
            to: [ { email: recipient } ],
            substitutions: {
              "-raw_subject-"=> subject,
              "-user_name-" => user.name,
              "-user_email-" => user.email,
              "-user_phone_number-" => user.phone_number,
              "-urgency-" => urgency,
              "-matter-" => matter,
              "-message-" => message,
              "-program-" => program,
              "-last_content-" => chaptercontent
            },
            subject: subject
          },
        ],
        from: {
          email: FROM
        },
        reply_to: {
          email: user.email, 
          name: user.name
        },
        attachments: [{
          filename: attachment.original_filename ,
          content: Base64.strict_encode64(File.read(attachment.tempfile)) ,
          type: attachment.content_type,
        }],
        template_id: "4969519e-b843-431d-8ccd-93123332ab0c"
      }
    end  
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

  def self.notify(subject, raw_subject, message, urgency, matter, user, chapter, signature, recipient,attachment)
    require "base64"
    if attachment.nil?
      data = {
        personalizations: [
          {
            to: [ { email: recipient } ],
            substitutions: {
              "-subject-"=> subject,
              "-raw_subject-" => raw_subject,
              "-user_name-" => user.name,
              "-user_email-" => user.email,
              "-user_phone_number-" => user.phone_number,
              "-urgency-" => urgency,
              "-matter-" => matter,
              "-message-" => message,
            },
            subject: subject
          },
        ],
        from: {
          email: FROM
        },
        reply_to: {
          email: "soporte@edc-digital.com", 
          name: "Soporte EDC"
        },
        template_id: "f0d0d83d-5ece-4737-86be-56790b432c15"
      }
    else 
      data = {
        personalizations: [
          {
            to: [ { email: recipient } ],
            substitutions: {
              "-subject-"=> subject,
              "-raw_subject-" => raw_subject,
              "-user_name-" => user.name,
              "-user_email-" => user.email,
              "-user_phone_number-" => user.phone_number,
              "-urgency-" => urgency,
              "-matter-" => matter,
              "-message-" => message,
            },
            subject: subject
          },
        ],
        from: {
          email: FROM
        },
        attachments: [{
          filename: attachment.original_filename ,
          content: Base64.strict_encode64(File.read(attachment.tempfile)) ,
          type: attachment.content_type,
        }],
        reply_to: {
          email: "soporte@edc-digital.com", 
          name: "Soporte EDC"
        },
        template_id: "f0d0d83d-5ece-4737-86be-56790b432c15"
      }
    end  

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
  def self.sin_grupo(user, state, university, url, group)
    data = {
        personalizations: [
          {
            to: [ { email: "soporte@edc-digital.com"} ],
            substitutions: {
              "-raw_subject-" => "EDC Digital - El estudiante #{user.name} no tiene grupo asignado.",
              "-user-"=> user.name,
              "-email-"=> user.email,
              "-state-" => state.name,
              "-university-" => university,
              "-url-" => url,
              "-group-" => group.name,
            },
            subject: "EDC Digital - El estudiante #{user.name} no tiene grupo asignado."
          },
        ],
        from: {
          email: FROM
        },
        template_id: "a5158a2b-1845-4f58-9c4a-4513a9703a95",
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
