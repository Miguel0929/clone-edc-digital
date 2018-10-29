class WelcomeAfterInvitation
  extend MailTemplateHelper

  def send_welcome_after_invitation(user, chosen_subject, root_link)
    template_title = "¡Es tiempo de iniciar!"
    template_name = "Hola"
    template_message = "Te damos la bienvenida a " + company_name_helper('nuestra plataforma') + ". Nos alegramos de tenerte con nosotros, puedes entrar a la plataforma desde aquí: </p> <table width='100%' cellspacing='0' cellpadding='0' border='0'><tbody><tr><td style='padding: 10px 10px 10px 10px' bgcolor: '#f8f8f8' align: 'center'><table cellspacing='0' cellpadding='0' border='0'><tbody><tr><td><a href='" + root_link + "' class='button'> INICIO >> </a></td></tr></tbody></table></td></tr></tbody></table></br><p style='margin-top: 20px;'>En caso de que no logres acceder, puedes copiar la siguiente liga y pegarla en una ventana de tu navegador:</p><a href='" + root_link + "' >" + root_link + "</a></br></br><p style='margin-top: 20px;'>Si tienes alguna duda o comentario, no dudes en escribirnos a <strong>" + mailer_from_helper('') + "</strong>. Nuestro equipo de atención a clientes enseguida te antenderá."
    template_footer = "¡Bienvenido!"
    mail_recipient = user.email
    mail_subject = chosen_subject

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

end		