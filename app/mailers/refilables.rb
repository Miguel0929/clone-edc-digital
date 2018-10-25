class Refilables
  extend MailTemplateHelper

	def self.up_rubric(template, user, ruta)

    template_title = "Rúbrica de plantilla actualizada"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Tu rúbrica de evaluación en la plantilla <strong>" + template.name + "</strong> ha sido actualizada recientemente.</p><p><a href='" + ruta + "'>Visita este enlace para verla >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Se ha actualizado tu rúbrica de evaluación de plantilla"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
	end

	def self.commented(template, user, ruta)

    template_title = "Nuevos comentarios en plantilla"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Tus respuestas a la plantilla <strong>" + template.name + "</strong> han sido comentadas por un mentor.</p><p><a href='" + ruta + "'>Visita este enlace para leer más >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Tus respuestas a una plantilla han sido comentadas"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
	end

end		