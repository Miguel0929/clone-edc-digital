class Dashboard::ChapterContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :track_chapter_content, only: [:show]

  def show
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
    if params[:subject].present? == false || params[:message].present? == false
      flash_message = { alert: 'Porfavor introduzca asunto y mensaje.'}
    else
      @recipients = [{adress: 'soporte-edcdigital@distritoemprendedor.com', type: 'soporte'}, {adress: current_user.email, type: 'usuario'}]
      @recipients.each do |recipient, index|
        if recipient[:type] == 'soporte'
          Support.contact(params[:subject], params[:message], params[:urgency], params[:matter], current_user, params[:chapter],params[:signature], recipient[:adress]).deliver_now
          flash_message = { notice: 'Su mensaje ha sido enviado.'}
        else
          Support.notify(params[:subject], params[:message], params[:urgency], params[:matter], current_user, params[:chapter],params[:signature], recipient[:adress]).deliver_now
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
