class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{}'>Estadisticas generales</a>".html_safe
    @users = User.all
    @mentor_messages = MentorHelp.all
    @massages = Mailboxer::Message.all
    @groups = Group.all
    @programs = Program.all
    @shared_attachments = SharedAttachment.all
    @attachments = Attachment.all
    @reports = Report.all
    @visits = Visit.where(started_at: 60.day.ago...Time.now)
    @total_activados = @users.where(invitation_created_at: @users.second.invitation_created_at...Time.now, 
                                  invitation_accepted_at: @users.second.invitation_created_at...Time.now).count - 
                                 @users.where(invitation_created_at: 6.month.ago...Time.now, 
                                            invitation_accepted_at: 6.month.ago...Time.now).count

    @total_creados = @users.where(invitation_created_at: @users.second.invitation_created_at...Time.now, 
                                invitation_accepted_at: nil).count -  
                               @users.where(invitation_created_at: 6.month.ago...Time.now, 
                                          invitation_accepted_at: nil).count
    total_activos = @total_activados
    @activados = (6.month.ago.to_date...Date.today).map do |date| 
      total_activos += @users.where(invitation_accepted_at: date.beginning_of_day...date.end_of_day).count
      [date.strftime('%Y-%m-%d'), total_activos] 
    end

    total_inactivos = @total_creados
    @inactivos = (6.month.ago.to_date...Date.today).map do |date|
      total_inactivos += @users.where(invitation_created_at: date.beginning_of_day...date.end_of_day, invitation_accepted_at: nil).count
      [date.strftime('%Y-%m-%d'), total_inactivos]
    end
    
    @promedio_sessiones = []
    Session.where( start:6.month.ago...Time.now).group_by(&:day).each do |day, session|
      tiempo = 0       
      session.each do |s|         
        tiempo += s.time.to_i       
      end       
      @promedio_sessiones << [day, tiempo]     
    end
  end
end
