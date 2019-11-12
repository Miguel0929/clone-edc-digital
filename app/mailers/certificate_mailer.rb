class CertificateMailer
	extend MailAttachmentTemplateHelper

	def self.certificate_sender(recipient_address, program, route, certificate_link, certificate)
		template_title = "Todo esfuerzo tiene recompensa"
		template_name = "Hola"
		support_mail = ENV['MAILER_SUPPORT'].nil? ? "Dirección no especificada" : ENV['MAILER_SUPPORT']
		platform_name = ENV['COMPANY_NAME'].nil? ? "nuestra plataforma" : ENV['COMPANY_NAME']
		#template_message = "Te felicitamos por haber terminado el programa <strong>" + program + "</strong> que pertenece al curso <strong>" + route + "</strong>. Te enviamos el certificado que acredita tu logro:</p><p><a href='" + certificate_link + "'>Visita este enlace para ver tu certificado >></a></p><p>Estamos para servirte, que tengas un excelente día."
		template_message = "El equipo de <em>" + platform_name + "</em> te felicita por haber terminado el programa <strong>" + program + "</strong> que pertenece al curso <strong>" + route + "</strong>. Te adjuntamos el certificado que acredita tu logro a este correo. En caso de que no puedas ver tu certificado comunícate a esta dirección: " + support_mail + ".</p><p>Estamos para servirte, que tengas un excelente día."
		template_footer = company_name_helper('Nuestro equipo')
		mail_recipient = recipient_address
		mail_subject = "Certificado del programa " + program

		send_mail_attachment_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject, certificate)

	end

end	