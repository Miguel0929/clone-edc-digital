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
    data = {
      personalizations: [
        {
          to: [ { email: email_address } ],
          substitutions: {
            "-user_emailaddress-"=> email_address,
            "-confirmation_link-" => ''
          },
          subject: "Tu cuenta de EDCdigital ha sido reactivada"
        },
      ],
      from: {
        email: "soporte-edcdigital@distritoemprendedor.com"
      },
      template_id: "21fa670a-a5f8-484c-960c-00fda450a692"
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
end
