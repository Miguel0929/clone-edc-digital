class CustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def reset_password_instructions(record, token, opts={})
    data = {
      personalizations: [
        {
          to: [ { email: record.email } ],
          substitutions: {
            "-confirmation_link-" => edit_password_url(record, reset_password_token: token)
          },
          subject: "Recupera tu contraseña en EDC Digital"
        },
      ],
      from: {
        email: "soporte-edcdigital@distritoemprendedor.com"
      },
      template_id: "d5b79cfe-a953-409f-b9a1-2767480f1b29"
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
