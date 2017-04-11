class Mentor::SharedAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :find_user
  before_action :set_attachment, only: [:edit, :update, :destroy]

  def new
    @attachment = @user.shared_attachments.new
  end

  def create
    @attachment = @user.shared_attachments.new(attachment_params)

    if @attachment.save
      redirect_to mentor_student_path(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @attachment.update(attachment_params)
      redirect_to mentor_student_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @attachment.destroy
    redirect_to mentor_student_path(@user)
  end

  private
  def attachment_params
    params.require(:shared_attachment).permit(:label, :file, :name, :document_type, :owner_id)
  end

  def set_attachment
    @attachment = @user.shared_attachments.find(params[:id])
  end

  def find_user
    @user = User.find(params[:student_id])
  end
end
