class Support < ApplicationMailer

  default from: 'soporte-edcdigital@distritoemprendedor.com'

  def contact(subject, message, urgency, matter, user, chapter, signature, recipient)
    @user, @subject, @message, @urgency, @matter, @chapter, @signature, @recipients = user, subject, message, urgency, matter, chapter, signature, recipient
    mail(to: recipient, subject: subject, reply_to: user.email)
  end
  def notify(subject, message, urgency, matter, user, chapter, signature, recipient)
    @user, @subject, @message, @urgency, @matter, @chapter, @signature, @recipients = user, subject, message, urgency, matter, chapter, signature, recipient
    attachments.inline["edc-logo-blanco-peque.jpg"] = File.read("app/assets/images/edc-logo-blanco-peque.jpg")
    mail(to: recipient, subject: subject, reply_to: user.email)
  end
end

