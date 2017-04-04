class Mentor::SharedGroupAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_attachment, only: [:edit, :update, :destroy]

  def index
    @shared_group_attachments = SharedGroupAttachment.joins(:shared_group_attachment_groups).where('shared_group_attachment_groups.group_id in (?)', current_user.groups.pluck(:id))
  end

  def new
    @attachment = SharedGroupAttachment.new
  end

  def create
    @attachment = SharedGroupAttachment.new(attachment_params)

    if @attachment.save
      redirect_to mentor_shared_group_attachments_path
    else
      render :new
    end
  end

  def edit
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
