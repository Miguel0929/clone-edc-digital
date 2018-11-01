class Mobile::SupportsController < Mobile::BaseController
  layout 'mobile'
  before_action :authorize
  skip_after_action :intercom_rails_auto_include

  def new
  end

  def create
    if params[:raw_subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'No olvides escribir asunto y mensaje.'}
    elsif params[:urgency] == 'none' || params[:matter] == 'none'
      flash_message = { alert: 'Recuerda seleccionar urgencia y clasificación.'}
    else
      MentorHelp.create(sender: current_user.id)
      unless params[:file].nil?
        uploaded_io=params[:file][:attachment]
        p uploaded_io.content_type
      end
      chapter = ("Sección de ayuda (<a class='active' href='" + root_url + "dashboard/ayuda'>puedes verla aquí</a>)").html_safe
      @recipients = [{adress: (ENV['MAILER_SUPPORT'].nil? ? "soporte@ejemplo.com" : ENV['MAILER_SUPPORT']), type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          subject = "Solicitud de soporte de " + (ENV['COMPANY_NAME'].nil? ? "la plataforma" : ENV['COMPANY_NAME']) + ": " + params[:raw_subject]
          Support.contact(subject, params[:message], params[:urgency], params[:matter], current_user, chapter, params[:signature], recipient[:adress], params[:program], params[:last_content], uploaded_io).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        else
          subject = "Recibimos tu mensaje: " + params[:raw_subject]
          Support.notify(subject, params[:raw_subject], params[:message], params[:urgency], params[:matter], current_user, chapter, params[:signature], recipient[:adress],uploaded_io).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        end
      end
    end

    redirect_to new_mobile_support_path(user_email: params[:user_email], user_token: params[:user_token]), flash_message
  end
end
