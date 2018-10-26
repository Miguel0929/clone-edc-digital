class SharedGroupAttachmentMailer
  extend MailTemplateHelper

  def self.shared_file(user, ruta)

    template_title = "Nuevo archivo para ti"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Hay un nuevo archivo compartido contigo en la plataforma. Para ver el archivo visita este enlace:</p><p><a href='" + ruta + "'>Ver nuevo archivo >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Hay un nuevo archivo compartido contigo"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

end		