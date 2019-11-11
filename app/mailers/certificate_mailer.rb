class CertificateMailer
	extend MailAttachmentTemplateHelper

	def self.certificate_sender(recipient_address, program, route, certificate_link, certificate)
		template_title = "Todo esfuerzo tiene recompensa"
		template_name = "Hola"
		template_message = "Te felicitamos por haber terminado el programa <strong>" + program + "</strong> que pertenece al curso <strong>" + route + "</strong>. Te enviamos el certificado que acredita tu logro:</p><p><a href='" + certificate_link + "'>Visita este enlace para ver tu certificado >></a></p><p>Estamos para servirte, que tengas un excelente día."
		#template_message = "El alumno " + student.name + " ha contestado la plantilla <strong>" + template_refilable.name + "</strong> del programa <strong>" + (program.nil? ? "Plantilla sin programa" : program.name) + "</strong>, te invitamos a que revises sus avances.</p><p><a href='" + ruta + "'>Visita este enlace para revisar avances >></a></p><p>Estamos para servirte, que tengas un excelente día."
		template_footer = company_name_helper('Nuestro equipo')
		mail_recipient = recipient_address
		mail_subject = "Certificado del programa " + program

		send_mail_attachment_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject, certificate)

	end

end	