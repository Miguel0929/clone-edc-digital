class ProgramAttachmentsController < ApplicationController
	before_action :authenticate_user!
  before_action :require_admin

  before_action :set_program
  before_action :set_attachment
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  add_breadcrumb "Programas", :programs_path

  def index
  	add_breadcrumb "<a href='#{program_path(@program)}'>#{@program.name}</a>".html_safe
  	add_breadcrumb "<a href='#{program_program_attachments_path(@program)}' class='active'>Archivos adjuntos</a>".html_safe
  	@program_attachments = ProgramAttachment.where(program: @program)
  end

  def new
  	add_breadcrumb "<a href='#{program_path(@program)}'>#{@program.name}</a>".html_safe
  	add_breadcrumb "<a href='#{program_program_attachments_path(@program)}'>Archivos adjuntos</a>".html_safe
  	add_breadcrumb "<a href='#{new_program_program_attachment_path(@program)}' class='active'>Nuevo archivo adjunto</a>".html_safe
  	@attachment = ProgramAttachment.new(program: @program)
  end

  def edit
  	add_breadcrumb "<a href='#{program_path(@program)}'>#{@program.name}</a>".html_safe
  	add_breadcrumb "<a href='#{program_program_attachments_path(@program)}'>Archivos adjuntos</a>".html_safe
  	add_breadcrumb "<a href='#{edit_program_program_attachment_path(@program, @attachment)}' class='active'>Editar archivo adjunto</a>".html_safe
  end	
  
  def create
  	 @attachment = ProgramAttachment.new(attachment_params)
  	 @attachment.program_id = @program.id

    if @attachment.save
      redirect_to program_program_attachments_path, notice: "Archivo adjunto creado."
    else
      render :new
    end
  end

  def update
  	if @attachment.update(attachment_params)
  	  redirect_to program_program_attachments_path, notice: "Archivo adjunto actualizado."
    else
      render :edit
    end
  end

  def destroy
  	@attachment.destroy
    redirect_to program_program_attachments_path, notice: "Archivo adjunto eliminado."
  end

  private
  def set_program
  	@program = Program.find(params[:program_id])
  end
  def set_attachment
  	@attachment = ProgramAttachment.where(id: params[:id], program: @program).first
  end	
  def attachment_params
    params.require(:program_attachment).permit(:label, :file, :name, :document_type, :program_id)
  end	
end
