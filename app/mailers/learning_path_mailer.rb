class LearningPathMailer
  extend MailTemplateHelper

	def self.up_learning_path(user, ruta)

    template_title = "Ruta de aprendizaje actualizada"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Tu ruta de aprendizaje ha sido actualizada en nuestra plataforma.</p><p><a href='" + ruta + "'>Visita este enlace para ver los cambios >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Tu ruta de aprendizaje ha sido actualizada"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
	end

end	