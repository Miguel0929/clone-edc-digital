class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.all
    @mentor_messages = MentorHelp.all
    @massages = Mailboxer::Message.all
    @groups = Group.all
    @programs = Program.all
    @shared_attachments = SharedAttachment.all
    @attachments = Attachment.all
    @reports = Report.all
    
    @promedio_sessiones = []
    Session.where( start: 30.day.ago...Time.now).group_by(&:day).each do |day, session|
      tiempo = 0
      session.each do |s|
        tiempo += s.time
      end
      @promedio_sessiones << [day, tiempo]
    end
  end
end
