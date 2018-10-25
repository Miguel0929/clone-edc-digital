class ProveSendgridController < ApplicationController
	include MailTemplateHelper
	before_action :authenticate_user!

	add_breadcrumb (ENV['HOME_BREADCRUMBS'].nil? ? 'Inicio' : ENV['HOME_BREADCRUMBS']), :root_path

	def index
		add_breadcrumb "<a class='active' href='#{prove_sendgrid_path}'>Enviar correo de prueba</a>".html_safe

	end

	def testing_sendgrid_mail

		template_title = "¡Comencemos!"
		template_name = "Jorgito"
		template_message = "Estamos preocupados por que la maestra dice que andas de buchonsín en la escuela, probablemente sea solo un rumor pero aparentemente los rumores tiene algo de verdad (por lo regular). Por lo tanto aplicaremos una pequeña operación mochila en la escuela para tu caso, así como una revisión a tu casillero."
		template_footer = "El Dire, we"
		mail_recipient = params[:email_to]
		mail_subject = "Buchonsín wanna be"

		send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)

		redirect_to prove_sendgrid_path, notice: "Terminado, revisa tu bandeja..."
		
	end

end
