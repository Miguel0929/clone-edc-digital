class Support < ApplicationMailer

  default from: 'soporte@edc-digital.com'

  def contact(subject, raw_subject, message, urgency, matter, user, chapter, signature, recipient)
    @user, @subject, @raw_subject, @message, @urgency, @matter, @chapter, @signature, @recipients = user, subject, raw_subject, message, urgency, matter, chapter, signature, recipient
    mail(to: recipient, subject: subject, reply_to: user.email)
  end
  def notify(subject, raw_subject, message, urgency, matter, user, chapter, signature, recipient)
    @user, @subject, @raw_subject, @message, @urgency, @matter, @chapter, @signature, @recipients = user, subject, raw_subject, message, urgency, matter, chapter, signature, recipient
    attachments.inline["edc-logo-blanco-peque.jpg"] = File.read("app/assets/images/edc-logo-blanco-peque.jpg")
    attachments.inline["firmacool.png"] = File.read("app/assets/images/firmacool.png")
    mail(to: recipient, subject: subject, reply_to: 'soporte@edc-digital.com')
  end
end

