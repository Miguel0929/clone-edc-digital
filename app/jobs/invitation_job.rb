class InvitationJob
  include MailTemplateHelper
  include SuckerPunch::Job
  workers 1

  def perform(name, email, group_id, url, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    user = User.unscoped.find_by(email: email)

    if user.nil?
      job["new_records"] = job["new_records"] + 1;
      job["new_emails"] = job["new_emails"] << email

      user = User.invite!(:email => email, :first_name => name, :group_id => group_id, :last_name => "x", :phone_number => "0000000000") do |u|
        u.skip_invitation = true
      end
      send_mail(user, url, job, job_id, redis)
    else
      if user.invitation_token.nil? && !user.invitation_accepted_at.nil?
        user.update(group_id: group_id)
        job["old_records_group"] = job["old_records_group"] + 1;
        job["old_emails_group"] = job["old_emails_group"] << email

        job["progress"] = job["progress"] + 1;
        redis.set(job_id, job.to_json)
      else 
        if (user.group_id != group_id) && user.deleted_at.nil?
          job["old_records_group"] = job["old_records_group"] + 1;
          job["old_emails_group"] = job["old_emails_group"] << email
        elsif user.deleted_at.nil?
          job["old_records"] = job["old_records"] + 1;
          job["old_emails"] = job["old_emails"] << email
        elsif user.deleted_at.nil? == false
          job["old_records_inactive"] = job["old_records_inactive"] + 1;
          job["old_emails_inactive"] = job["old_emails_inactive"] << email
        end
        user.update(group_id: group_id, :last_name => "x", :phone_number => "0000000000")
        user.invite! do |u|
          u.skip_invitation = true
        end
        send_mail(user, url, job, job_id, redis)
      end
    end
  end

  def send_mail(user, url, job, job_id, redis)

      invitation_link = url + "?invitation_token=" + user.raw_invitation_token

      template_title = "¡Es tiempo de iniciar!"
      template_name = "Hola"
      template_message = "Te informamos que tu cuenta en " + company_name_helper('nuestra plataforma') + " ha sido creada. Para comenzar, debes activar tu cuenta dando clic en el siguiente botón: </p> <table width='100%' cellspacing='0' cellpadding='0' border='0'><tbody><tr><td style='padding: 10px 10px 10px 10px' bgcolor: '#f8f8f8' align: 'center'><table cellspacing='0' cellpadding='0' border='0'><tbody><tr><td><a href='" + invitation_link + "' class='button'>ACTIVA TU CUENTA AQUÍ</a></td></tr></tbody></table></td></tr></tbody></table></br><p style='margin-top: 20px;'>En caso de que no logres acceder, puedes copiar la siguiente liga y pegarla en una ventana de tu navegador:</p><a href='" + invitation_link + "' >" + invitation_link + "</a></br></br><p style='margin-top: 20px;'>Si tienes alguna duda o comentario, no dudes en escribirnos a <strong>" + mailer_from_helper('') + "</strong>. Nuestro equipo de atención a clientes enseguida te antenderá."
      template_footer = "¡Bienvenido!"
      mail_recipient = user.email
      mail_subject = "Tu cuenta en " + company_name_helper('nuestra plataforma') + " ha sido creada"

      send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)

  end

end