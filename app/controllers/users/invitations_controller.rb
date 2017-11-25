class Users::InvitationsController < Devise::InvitationsController
  before_action :require_creator, only: [:new]
  before_action :set_breadcrumb, only: [:new, :create]
  def after_invite_path_for(resource)
    new_user_invitation_path
  end

  private

  def invite_resource
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
            subject: "Tu cuenta en EDCdigital ha sido creada"
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
  BaasstardNotifier.user_invited(resource) rescue nil
  resource
end
end
