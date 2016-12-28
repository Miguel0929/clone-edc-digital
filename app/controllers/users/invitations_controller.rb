class Users::InvitationsController < Devise::InvitationsController
  before_action :require_admin, only: [:new]
  before_action :set_breadcrumb, only: [:new, :create]


  private

  def invite_resource
    user = super do |u|
      u.skip_invitation = true if Rails.env.production?
    end

    if Rails.env.production?
      Mailjet::Send.create(
        from_email: "hola@emprendiendodesdecero.com",
        from_name: "Equipo EDCdigital",
        subject: "Tu cuenta en EDCdigital ha sido creada",
        "Mj-TemplateID": "67867",
        "Mj-TemplateLanguage": "true",
        recipients: [{ 'Email'=> user.email }],
        vars: {
          "confirmation_link" => accept_user_invitation_url(:invitation_token => user.raw_invitation_token)
        }
      )
    end

    user
  end

  def set_breadcrumb
    add_breadcrumb "Administrador", :root_path
    add_breadcrumb "<a class='active' href='#{new_user_invitation_path}'>Enviar invitación</a>".html_safe
  end
end
