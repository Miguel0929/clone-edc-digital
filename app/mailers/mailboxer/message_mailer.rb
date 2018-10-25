class ::Mailboxer::MessageMailer < Mailboxer::BaseMailer
  include MailTemplateHelper
  include Rails.application.routes.url_helpers

  def send_email(notification, receiver)

    p "======== MessageMailer ========"

    template_title = "Respuesta a mensaje"
    template_name = (receiver.first_name.nil? ?  "Hola" : receiver.name)
    template_message = "Tienes una nueva respuesta al mensaje: <strong>" + notification.subject + "</strong>.</p><p>La respuesta es: <strong>" + notification.body + "</strong>. <p> Visita <a href='" + root_url + "mailbox/inbox" + "'>" + root_url + "mailbox/inbox" + "</a> para leer tus mensajes."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = receiver.email
    mail_subject = "Respuesta a mensaje: " + notification.subject

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end
end
