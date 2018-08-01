class Users::InvitationsController < Devise::InvitationsController
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
      data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-confirmation_link-" => accept_user_invitation_url(:invitation_token => user.raw_invitation_token)
            },
            subject: "Tu cuenta en EDC Digital ha sido creada"
          },
        ],
        from: {
          email: "soporte@edc-digital.com"
        },
        template_id: "506fcba3-80ce-4de9-bb7f-41e1e752ce0f"
      }

      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      begin
        response = sg.client.mail._("send").post(request_body: data)
        Rails.logger.info response.status_code
        Rails.logger.info response.body
        Rails.logger.info response.headers
        FakeEmail.new
      rescue Exception => e
        Rails.logger.info e.message
        FakeEmail.new
      end
    end

    flash[:notice] = "Se ha enviado una invitación de nuevo usuario al correo #{user.email}"
    user
  end

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
    route_link = request.base_url + dashboard_learning_path_path
    more_link = "https://www.edc-megatendencias.com"
    privacy_link = user.student? ? (request.base_url + dashboard_privacy_path) : (request.base_url + progress_panel_index_path)
    faqs_link = user.student? ? (request.base_url + frequent_questions_path) : (request.base_url + mentor_shared_group_attachments_path)
    mailer_template = user.student? ? "41b96136-9eb4-4943-9a39-455dbfd3e1cc" : "400655aa-4a5f-4e73-8f09-11d243d48e0e"
    variable_text = user.student? ? 
                    "Tenemos la misión de darte la mejor experiencia en nuestra plataforma, es por eso que te presentamos a continuación los <strong>4 grandes beneficios</strong> que comprende tu membresía:" : 
                    "Nuestra misión es darte la mejor experiencia en la plataforma y ayudarte a dar un acompañamiento oportuno a tus alumnos.<br><br><strong>Te presentamos las principales herramientas que usarás en EDC Digital</strong>:"
    WelcomeAfterInvitation.send_welcome_message(user, chosen_subject, root_link, route_link, more_link, privacy_link, faqs_link, variable_text, mailer_template)
  end
end
