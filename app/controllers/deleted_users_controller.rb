class DeletedUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:update]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{deleted_users_path}'>Usuarios desactivados</a>".html_safe

    @users = User.includes(:group).only_deleted
  end

  def update
    @user.restore

    if @user.invitation_accepted_at.nil?
      send_reactivation_email(90816, @user.email)
    else
      send_reactivation_email(90812, @user.email)
    end

    redirect_to deleted_users_path, notice: "Se reactivó exitosamente al usuario #{@user.email}"
  end

  private
  def set_user
    @user = User.only_deleted.find(params[:id])
  end

  def send_reactivation_email(template_id, email_address)
    Mailjet::Send.create(
      from_email: "soporte-edcdigital@distritoemprendedor.com",
      from_name: "Soporte EDCdigital",
      subject: "Tu cuenta de EDCdigital ha sido reactivada",
      "Mj-TemplateID": template_id,
      "Mj-TemplateLanguage": "true",
      recipients: [{ 'Email'=> email_address}],
      vars: {
        "user_emailaddress" => email_address
      }
    )
  end
end
