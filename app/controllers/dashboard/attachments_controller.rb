class Dashboard::AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_support, if: :student_have_group?
  before_action :set_attachment, only: [:edit, :update, :destroy]
  add_breadcrumb "EDC DIGITAL", :root_path

  include ActiveElementsHelper

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_attachments_path}'>Mis archivos</a>".html_safe

    @attachments = current_user.attachments

    @program_attachment = get_active_elements(current_user, "program_attachments")
  end

  def new
    add_breadcrumb "Mis archivos", :dashboard_attachments_path
    add_breadcrumb "<a class='active' href='#{new_dashboard_attachment_path}'>Subir archivo</a>".html_safe

    @attachment = current_user.attachments.new
  end

  def create
    @attachment = current_user.attachments.new(attachment_params)

    if @attachment.save
      redirect_to dashboard_attachments_path
    else
      render :new
    end
  end

  def edit
    add_breadcrumb "Mis archivos", :dashboard_attachments_path
    add_breadcrumb "<a class='active' href='#{dashboard_attachment_path(@attachment)}'>Editar archivo</a>".html_safe
  end

  def update
    if @attachment.update(attachment_params)
      redirect_to dashboard_attachments_path
    else
      render :edit
    end
  end

  def destroy
    @attachment.destroy
    redirect_to dashboard_attachments_path
  end

  private
  def attachment_params
    params.require(:attachment).permit(:label, :file, :name, :document_type)
  end

  def set_attachment
    @attachment = current_user.attachments.find(params[:id])
  end
end
