class Users::InvitationsController < Devise::InvitationsController
  include MailTemplateHelper
  before_action :require_creator, only: [:new]
  before_action :set_breadcrumb, only: [:new, :create]
  def after_invite_path_for(resource)
    new_user_invitation_path
  end

  private

  def invite_resource
    accept_resource
    user = super do |u|
      u.skip_invitation = true if Rails.env.production?
    end
       
    BaasstardNotifier.user_invited(user) rescue nil

    if Rails.env.production?

      invitation_link = accept_user_invitation_url(:invitation_token => user.raw_invitation_token).to_s
      to_group = user.group_id.nil? ? nil : Group.find(user.group_id)
      to_group_name = to_group.nil? ? "[Grupo sin nombre]" : to_group.name
      to_group_university = to_group.nil? ? nil : to_group.university
      to_group_university_name = to_group_university.nil? ? "[Institución sin nombre]" : to_group_university.name

      template_title = "¡Es tiempo de iniciar! Perritos"
      template_name = ""
      template_group = "Has sido invitado al grupo " + to_group_name + (to_group_university.nil? ? ". " : " vinculado a esta Institución: " + to_group_university_name + ". ")
      template_message = "Te informamos que tu cuenta en " + company_name_helper('nuestra plataforma') + " ha sido creada. " + template_group + "Para comenzar, debes activar tu cuenta dando clic en el siguiente botón: </p> <table width='100%' cellspacing='0' cellpadding='0' border='0'><tbody><tr><td style='padding: 10px 10px 10px 10px' bgcolor: '#f8f8f8' align: 'center'><table cellspacing='0' cellpadding='0' border='0'><tbody><tr><td><a href='" + invitation_link + "' class='button'>ACTIVA TU CUENTA AQUÍ</a></td></tr></tbody></table></td></tr></tbody></table></br><p style='margin-top: 20px;'>En caso de que no logres acceder, puedes copiar la siguiente liga y pegarla en una ventana de tu navegador:</p><a href='" + invitation_link + "' >" + invitation_link + "</a></br></br><p style='margin-top: 20px;'>Si tienes alguna duda o comentario, no dudes en escribirnos a <strong>" + mailer_from_helper('') + "</strong>. Nuestro equipo de atención a clientes enseguida te antenderá."
      template_footer = "¡Bienvenido!"
      mail_recipient = user.email
      mail_subject = "Tu cuenta en " + company_name_helper('nuestra plataforma') + " ha sido creada"

      send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
      
    end

    flash[:notice] = "Se ha enviado una invitación de nuevo usuario al correo #{user.email}"
    user
  end

  #def invite_resource
  #  accept_resource
  #  user = super do |u|
  #    u.skip_invitation = true if Rails.env.production?
  #  end
  #     
  #  BaasstardNotifier.user_invited(user) rescue nil
  #
  #  if Rails.env.production?
  #    data = {
  #      personalizations: [
  #        {
  #          to: [ { email: user.email } ],
  #          substitutions: {
  #            "-confirmation_link-" => accept_user_invitation_url(:invitation_token => user.raw_invitation_token)
  #          },
  #          subject: "Tu cuenta " + (ENV['COMPANY_NAME'].nil? ? "la plataforma" : ENV['COMPANY_NAME']) + " ha sido creada"
  #        },
  #      ],
  #      from: {
  #        email: (ENV['MAILER_SUPPORT'].nil? ? "la plataforma" : ENV['MAILER_SUPPORT'])
  #      },
  #      template_id: "506fcba3-80ce-4de9-bb7f-41e1e752ce0f"
  #    }
  #
  #    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  #    begin
  #      response = sg.client.mail._("send").post(request_body: data)
  #      Rails.logger.info response.status_code
  #      Rails.logger.info response.body
  #      Rails.logger.info response.headers
  #      FakeEmail.new
  #    rescue Exception => e
  #      Rails.logger.info e.message
  #      FakeEmail.new
  #    end
  #  end
  #
  #  flash[:notice] = "Se ha enviado una invitación de nuevo usuario al correo #{user.email}"
  #  user
  #end

  def set_breadcrumb
    add_breadcrumb "Administrador", :root_path
    add_breadcrumb "<a class='active' href='#{new_user_invitation_path}'>Enviar invitación</a>".html_safe
  end

  def accept_resource
    resource = resource_class.accept_invitation!(update_resource_params)
    if current_user.nil?
      send_welcome_after_invitation(resource)
      if Date.valid_date?(params[:user_detail]['birthdate(1i)'.to_sym].to_i, params[:user_detail]['birthdate(2i)'.to_sym].to_i, params[:user_detail]['birthdate(3i)'.to_sym].to_i)
        new_birthdate = (params[:user_detail]['birthdate(3i)'.to_sym] + "/" + params[:user_detail]['birthdate(2i)'.to_sym] + "/" + params[:user_detail]['birthdate(1i)'.to_sym]).to_date
      else
        new_birthdate = nil
      end
      user_detail = UserDetail.find_or_initialize_by(user_id: resource.id)
      user_detail.birthdate =  new_birthdate
      user_detail.save
    end
    BaasstardNotifier.user_invited(resource) rescue nil
    resource
  end

  def send_welcome_after_invitation(user)
    chosen_subject = user.student? ? "¡Bienvenidos, alumnos!" : "¡Bienvenidos, profesores!"
    root_link = request.base_url
    WelcomeAfterInvitation.send_welcome_message(user, chosen_subject, root_link)
  end
end
