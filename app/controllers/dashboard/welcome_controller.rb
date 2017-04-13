class Dashboard::WelcomeController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{root_path}'>Inicio</a>".html_safe
  end

  def terms
    add_breadcrumb "<a class='active' href='#{dashboard_terms_path}'>TÉRMINOS DE SERVICIO</a>".html_safe
  end

  def privacy
    add_breadcrumb "<a class='active' href='#{dashboard_privacy_path}'>POLÍTICA DE PRIVACIDAD</a>".html_safe
  end

  def support
    add_breadcrumb "<a class='active' href='#{dashboard_support_path}'>Ayuda</a>".html_safe
  end

  def service
    add_breadcrumb "<a class='active' href='#{dashboard_support_path}'>TÉRMINOS DE SERVICIO</a>".html_safe
  end

  def send_support_email

    if params[:subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'Porfavor introduzca asunto y mensaje.'}
    else
      chapter = "Sección de ayuda (<a class='active' href='www.edcdigital.mx/dashboard/ayuda'>puedes verla aquí</a>)".html_safe
      @recipients = [{adress: 'soporte-edcdigital@distritoemprendedor.com', type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          Support.contact(params[:subject], params[:message], params[:urgency], params[:matter], current_user, chapter, params[:signature], recipient[:adress]).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        else
          Support.notify(params[:subject], params[:message], params[:urgency], params[:matter], current_user, chapter, params[:signature], recipient[:adress]).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        end
      end
    end

    redirect_to dashboard_support_path, flash_message
  end
end
