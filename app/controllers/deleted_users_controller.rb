class DeletedUsersController < ApplicationController
  include MailTemplateHelper
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:update]

  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{deleted_users_path}'>Usuarios desactivados</a>".html_safe

    @users = User.includes(:group).only_deleted

    respond_to do |format|
      format.html {}
      format.xlsx
    end 
  end

  def update
    @user.restore

    if @user.invitation_accepted_at.nil?
      send_reactivation_email(90816, @user)
    else
      send_reactivation_email(90812, @user)
    end

    redirect_to deleted_users_path, notice: "Se reactivó exitosamente al usuario #{@user.email}"
  end

  private
  def set_user
    @user = User.only_deleted.find(params[:id])
  end

  def self.send_reactivation_email(template, user)

    template_title = "¡Reactivamos tu cuenta!"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Te informamos que tu cuenta en " + company_name_helper('la plataforma') + " ha sido reactivada. Utiliza el siguiente botón para ingresar nuevamente a la plataforma y hacer inicio de sesión:</p><p><a href='" + "#" + "'>Iniciar sesión >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Tu cuenta ha sido reactivada"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

end
