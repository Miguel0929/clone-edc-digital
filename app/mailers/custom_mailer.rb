class CustomMailer < Devise::Mailer
  include MailTemplateHelper
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def reset_password_instructions(record, token, opts={})

    puts "record"
    puts record
    puts "token"
    puts token
    puts "opts"
    puts opts
    puts "link"
    puts edit_password_url(record, reset_password_token: token)

    template_title = "Recupera tu contraseña"
    template_name = (record.first_name.nil? ? "Hola" : record.name)
    #template_message = "¿Tuviste problemas para recordar tu contraseña? Sigue el siguiente enlace para recuperarla:</p><table><tr><td align='center'><a href='" + edit_password_url(record, reset_password_token: token) + "'><h4>Cambiar contraseña</h4></a></td></tr><tr></table><p>Continuamos en contacto contigo."
    template_message = "token " token.to_s + " record " + token.to_s + " link " + edit_password_url(record, reset_password_token: token).to_s
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = record.email
    mail_subject = "Recupera tu contraseña de la plataforma"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

end
