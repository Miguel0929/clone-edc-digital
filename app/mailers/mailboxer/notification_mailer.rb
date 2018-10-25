class ::Mailboxer::NotificationMailer < Mailboxer::BaseMailer
  include MailTemplateHelper
  include Rails.application.routes.url_helpers

  def send_email(notification, receiver)

    p "======== NotificationMailer ========"

    template_title = "Notificación de mensaje"
    template_name = "Hola"
    template_message = "Notificación de mensaje"
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = mailer_support_helper
    mail_subject = "Notificación de mensaje"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end
end