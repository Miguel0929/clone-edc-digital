class Support < ApplicationMailer
  def contact(subject, message, urgency, user)
    @user, @subject, @message, @urgency = user, subject, message, urgency
    mail(to: 'soporte-edcdigital@distritoemprendedor.com', subject: subject)
  end
end
