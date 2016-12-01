class CustomMailer < Devise::Mailer   
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def reset_password_instructions(record, token, opts={})
    Mailjet::Send.create(
      from_email: "soporte-edcdigital@distritoemprendedor.com",
      from_name: "Soporte EDCdigital",
      subject: "Recupera tu contraseña en EDCdigital",
      "Mj-TemplateID": "75219",
      "Mj-TemplateLanguage": "true",
      recipients: [{ 'Email'=> record.email }],
      vars: {
        "confirmation_link" => edit_password_url(record, reset_password_token: token)
      }
    )
  end
end
