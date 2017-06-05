require 'csv'

class GroupInvitationsController < ApplicationController
  def new
  end

  def create
    if params[:csv].blank? || params[:group_id].blank?
      flash[:alert] = 'Se requiere un archivo'
      redirect_to new_group_invitation_path
    else
      CSV.foreach(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8') do |row|
        InvitationJob.perform_async(row['NOMBRE'], row['CORREO'], params[:group_id], accept_user_invitation_url)
      end

      flash[:notice] = "Invitaciones enviadas"

      redirect_to new_group_invitation_path
    end
  end
end
