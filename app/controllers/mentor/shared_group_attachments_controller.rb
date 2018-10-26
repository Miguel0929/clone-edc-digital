class Mentor::SharedGroupAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_attachment, only: [:edit, :update, :destroy]
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{mentor_shared_group_attachments_path}'>Archivos compartidos</a>".html_safe
    @shared_group_attachments = SharedGroupAttachment.joins(:shared_group_attachment_groups).where('shared_group_attachment_groups.group_id in (?)', current_user.groups.pluck(:id))
  end

  def new
    add_breadcrumb "Archivos compartidos", :mentor_shared_group_attachments_path
    add_breadcrumb "<a class='active' href='#{new_mentor_shared_group_attachment_path}'>Subir archivo</a>".html_safe
    @attachment = SharedGroupAttachment.new
  end

  def create
    @attachment = SharedGroupAttachment.new(attachment_params)

    if @attachment.save
      SharedGroupAttachmentNotificationJob.perform_async(@attachment, dashboard_attachments_url)
      redirect_to mentor_shared_group_attachments_path
    else
      render :new
    end
  end

  def edit
    add_breadcrumb "Archivos compartidos", :mentor_shared_group_attachments_path
    add_breadcrumb "<a class='active' href='#{edit_mentor_shared_group_attachment_path}'>Editar archivo</a>".html_safe
  end

  def update
    if @attachment.update(attachment_params)
      redirect_to mentor_shared_group_attachments_path
    else
      render :edit
    end
  end

  def destroy
    @attachment.destroy
    redirect_to mentor_shared_group_attachments_path
  end

  private
  def attachment_params
    params.require(:shared_group_attachment).permit(:label, :file, :name, :document_type, :owner_id, group_ids: [])
  end

  def set_attachment
    @attachment = SharedGroupAttachment.find(params[:id])
  end
end
