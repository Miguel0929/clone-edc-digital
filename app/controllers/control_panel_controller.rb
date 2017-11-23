class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  add_breadcrumb "EDC DIGITAL", :root_path

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

    @activados = User.where(invitation_created_at: 6.months.ago.to_date..Date.today).where.not(invitation_accepted_at: nil).select('invitation_created_at, count(invitation_created_at) as total')
    .group(:invitation_created_at).map {|user| [user.invitation_created_at.strftime('%Y-%m-%d'), user.total]}

    @inactivos = User.where(invitation_created_at: 6.months.ago.to_date..Date.today, invitation_accepted_at: nil).select('invitation_created_at, count(invitation_created_at) as total')
    .group(:invitation_created_at).map {|user| [user.invitation_created_at.strftime('%Y-%m-%d'), user.total]}

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
