class CustomMailer < Devise::Mailer
  include MailTemplateHelper
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def reset_password_instructions(record, token, opts={})

    raw_link = edit_password_url(record, reset_password_token: token)
    if Rails.env.production?
      if raw_link.include?(ENV["PRODUCTION_IP"])
        final_link = ENV['COMPANY_LINK'] + raw_link[raw_link.index(ENV["PRODUCTION_IP"]) + ENV["PRODUCTION_IP"].size, raw_link.size]
      else 
        final_link = raw_link
      end
    else
      final_link = raw_link
    end

    template_title = "Recupera tu contraseña"
    template_name = (record.first_name.nil? ? "Hola" : record.name)
    #template_message = "¿Tuviste problemas para recordar tu contraseña? Sigue el siguiente enlace para recuperarla:</p><table><tr><td align='center'><a href='" + final_link + "'><h4>Cambiar contraseña</h4></a></td></tr><tr></table><p>Continuamos en contacto contigo."
    template_message = "token " + token.to_s + " record " + record.to_s + " link " + final_link.to_s
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = record.email
    mail_subject = "Recupera tu contraseña de la plataforma"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

end
