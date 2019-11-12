class CertificateTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_certificate_template, only: [:edit, :update, :destroy]
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path
  
  def index 
    add_breadcrumb "<a class='active' href='#{certificate_templates_path}'>Plantillas de Certificado</a>".html_safe
    @certificate_templates = CertificateTemplate.all.page(params[:page]).per(30)
  end

  def edit
  end

  def update
    if !params[:main_checkbox].nil? then @certificate_template.main = true end
    if @certificate_template.update(certificate_template_params)
      if !params[:main_checkbox].nil? then CertificateTemplate.where(main: true).where.not(id: @certificate_template.id).map{ |certemp| certemp.update(main: false) } end
      redirect_to certificate_templates_path, notice: "Se editó exitosamente la plantilla: #{@certificate_template.name}"
    else
      render :edit
    end
  end

  def new
    add_breadcrumb "Plantillas de Certificado", :certificate_templates_path
    add_breadcrumb "<a class='active' href='#{new_certificate_template_path(tipo: "contanciaindividual")}'>Nueva plantilla</a>".html_safe
    @certificate_template = CertificateTemplate.new
  end

  def create
    @certificate_template = CertificateTemplate.new(certificate_template_params)
    if params[:main_checkbox].nil?
      @certificate_template.main = false
    else
      @certificate_template.main = true
    end

    if @certificate_template.save
      if !params[:main_checkbox].nil? then CertificateTemplate.where(main: true).where.not(id: @certificate_template.id).map{ |certemp| certemp.update(main: false) } end
      redirect_to certificate_templates_path, notice: "Se creo exitosamente la plantilla: #{@certificate_template.name}"
    else
      redirect_to new_certificate_template_path, alert: "Ocurrió un error, por favor intente de nuevo"
    end
  end

  def destroy
    @certificate_template.destroy

    redirect_to certificate_templates_path, notice: "Se eliminó exitosamente la plantilla: #{@certificate_template.name}"
  end

  private
  def certificate_template_params
    params.require(:certificate_template).permit(:name, :file)
  end

  def set_certificate_template
    @certificate_template = CertificateTemplate.find(params[:id])
  end
end
