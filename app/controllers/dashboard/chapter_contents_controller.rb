class Dashboard::ChapterContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :track_chapter_content, only: [:show]

  def show
    rank= Rating.where(ratingable_type: "ChapterContent", ratingable_id: @chapter_content.id, user_id: current_user.id).first
    if rank.nil?
      @rank=0
    else
      @rank=rank.rank
    end  
    if @chapter_content.coursable_type == 'Question'
      redirect_to router_dashboard_chapter_content_answers_path(@chapter_content), status: 301
    else
      add_breadcrumb "EDCDIGITAL", :root_path
      add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
      add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.identifier}</a>".html_safe
    end
  end

  #Nuevo: datos para el correo
  def mailer_interno
    if params[:raw_subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'ERROR: No olvides escribir asunto y mensaje.'}
    elsif params[:urgency] == 'none' || params[:matter] == 'none'
      flash_message = { alert: 'ERROR: Recuerda seleccionar nivel de urgencia y clasificación.'}
    else
      @recipients = [{adress: 'soporte@edc-digital.com', type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          subject = "Solicitud de soporte EDC-Digital: " + params[:raw_subject]
          Support.contact(subject, params[:message], params[:urgency], params[:matter], current_user, params[:chapter],params[:signature], recipient[:adress]).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        else
          subject = "Recibimos tu mensaje: " + params[:raw_subject]
          Support.notify(subject, params[:raw_subject], params[:message], params[:urgency], params[:matter], current_user, params[:chapter],params[:signature], recipient[:adress]).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        end
      end
    end

    redirect_to router_dashboard_chapter_content_answers_path, flash_message
  end

  private
  def track_chapter_content
    @chapter_content = ChapterContent.find(params[:id])
    if Tracker.find_by(chapter_content: @chapter_content, user: current_user).nil?
      Tracker.create(chapter_content: @chapter_content, user: current_user)
    end

    ahoy.track "Viewed content", chapter_content_id: @chapter_content.id
  end
end
