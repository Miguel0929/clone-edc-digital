require 'csv'
require 'json'

class GroupInvitationsController < ApplicationController
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  def new
    add_breadcrumb "<a class='active' href='#{new_group_invitation_path}'>Invitaciones en grupo</a>".html_safe
  end

  def create
    if params[:csv].blank? || params[:group_id].blank?
      flash[:alert] = 'Se requiere un archivo'
      redirect_to new_group_invitation_path
    else
      total = CSV.read(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8').size

      timestamp = Time.current.to_i
      emails = []
      redis = Redis.new
      redis.set("job_#{timestamp}", {
        total: total,
        progress: 0,
        new_records: 0,
        old_records: 0,
        old_records_group: 0,
        old_records_inactive: 0,
        new_emails: [],
        old_emails: [],
        old_emails_group: [],
        old_emails_inactive: [],
      }.to_json)

      CSV.foreach(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8') do |row|
        InvitationJob.perform_async(row['NOMBRE'].downcase, row['CORREO'], params[:group_id], accept_user_invitation_url, "job_#{timestamp}")
      end

      flash[:notice] = "Invitaciones enviadas"
      redirect_to group_invitation_path(timestamp)
    end
  end

  def show
    @job_id = params[:id]
  end

  def export_codes
    emails = JSON.parse(params[:emails])
    mails = []
    emails.each{|e| mails.push(e["email"])}
    @active_students = User.where(email: mails, invitation_token: nil)
    @inactive_students = User.where(email: mails).where.not(invitation_token: nil)

    if @active_students.count > 0
      @group = @active_students.first().group
    elsif @inactive_students.count > 0 
      @group = @inactive_students.first().group
    else
      @group = nil 
    end  
  end  
end
