require 'csv'

class GroupInvitationsController < ApplicationController
  add_breadcrumb "EDCDIGITAL", :root_path
  def new
    add_breadcrumb "<a class='active' href='#{new_group_invitation_path}'>Invitaciones en grupo</a>".html_safe
  end

  def create
    if params[:csv].blank? || params[:group_id].blank?
      flash[:alert] = 'Se requiere un archivo'
      redirect_to new_group_invitation_path
    else
      total = CSV.read(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8').size

      job = AsyncJob.create({title: 'Inviting users', progress: 0, total: total})

      CSV.foreach(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8') do |row|
        InvitationJob.perform_async(row['NOMBRE'], row['CORREO'], params[:group_id], accept_user_invitation_url, job)
      end

      flash[:notice] = "Invitaciones enviadas"

      redirect_to group_invitation_path(job)
    end
  end

  def show
    @job_id = params[:id]
  end
end
