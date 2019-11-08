# encoding: UTF-8
require 'csv'
require 'open-uri'

class CertificatesController < ApplicationController
  include ActionView::Helpers::DateHelper
  before_action :authenticate_user!
  before_action :require_admin, only: [:new]
  layout 'application', only: [:index, :new, :create, :destroy, :batch, :edit_batch, :zip_progress, :unsuccessful]
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

=begin
  def index
    add_breadcrumb "<a class='active' href='#{certificates_path(tipo: "nuevocompilado")}'>Compilado de certificados</a>".html_safe
    @certificates = Certificate.select('batch as name').group(:batch)#.page(params[:page]).per(30)
  end

  def show
    @certificate = Certificate.find(params[:id])

    render :pdf => "certificado",
            :layout => "certificates.html",
          encoding: 'utf8',
            margin:  {
              top:               0,
              bottom:            0,
              left:              0,
              right:             0
            }
  end
=end

  def new
    #add_breadcrumb "<a href='#{certificates_path(tipo: "nuevocompilado")}'>Compilado de certificados</a>".html_safe
    add_breadcrumb "Plantillas de Certificado", :certificates_path
    add_breadcrumb "<a class='active' href='#{new_certificate_path}'>Nuevo certificado</a>".html_safe
    @certificate = Certificate.new
  end

  def create
    puts "hola pistola"
    puts certificate_params
    puts params[:mailer_checkbox].nil?
    puts localize(Date.today, format: "%e de %B, %Y").capitalize

    @certificate = Certificate.new(certificate_params)
    @certificate.date = localize(Date.today, format: "%d-%m-%Y")
    @certificate.batch = "none"
    tempfile = pdf_file

    #dbx = Dropbox::Client.new("AbqBJp667rAAAAAAAADrxE3K3jEoOr6HwM7_blQWFZlOC3wwb--TpxrIjcklss1g")
    #file = dbx.upload( "/Onne/onne-team (FEW)/Constancias Baasstard/#{@certificate.batch}/#{Date.today.to_s}/#{@certificate.name.split(' ').join('_')}.pdf", File.open(tempfile.path)) # => Dropbox::FileMetadata

    @certificate.file = File.open(tempfile.path)
    #@certificate.dropbox_file = File.open(tempfile.path)

    if @certificate.save
      tempfile.unlink
      if params[:mailer_checkbox].nil?
        redirect_to :back, notice: 'El certificado fue creado'
      else
        params[:id] = @certificate.id
        params[:individual] = true
        send_email
      end
    else
      puts @certificate.errors.full_messages
      render :new
    end
  end

=begin
  def import
    unless params[:csv].blank? || params[:batch].blank? || params[:date].blank?
      certificate_template = params[:certificate_template_id]
      numrows = CSV.read(params[:csv].tempfile,  encoding: 'r:ISO-8859-15:UTF-8').size - 1
      csv_records = not_repeated_records
      repeated = numrows - csv_records.size
      how_long = distance_of_time_in_words(0, csv_records.size * 5)
      row_count = 0
      names_list = []
      job = AsyncJob.create({ total: csv_records.size, progress: 0 })

      batch = Sidekiq::Batch.new
      batch.on(:success, CertificateWorkerSQL, 'job_id' => job.id)
      puts batch.description = "Batch #{batch.bid}, certifaciones con correo"
      SidekiqbatchSqlJob.perform_async(params[:csv], params[:batch], batch, certificate_template, job, numrows)

      redirect_to batch_certificates_path(job_id: job.id, name: params[:batch], bid: batch.bid, repeated: repeated, numrows: numrows), notice: 'Este proceso tardará ' + how_long
    else
      redirect_to certificates_path, notice: 'Verifica que los campos esten completos'
    end
  end

  def batch
    add_breadcrumb "<a href='#{certificates_path(tipo: "nuevocompilado")}'>Compilado de certificados</a>".html_safe
    add_breadcrumb "<a class='active' href='#{batch_certificates_path(name: params[:name], tipo: "contanciaindividual" )}'>#{params[:name]}</a>".html_safe
    @certificates = Certificate.where('batch = ?', params[:name]).page(params[:page]).per(30)
  end
=end

  def send_email
    certificate = Certificate.find(params[:id])

    data = {
      personalizations: [
        {
          to: [ { email: certificate.email } ],
          substitutions: {
            "-certificate_url-" => certificate.file.url
          },
          subject: "Constancia de participación Emprendiendo desde Cero"
        },
      ],
      from: {
        email: "hola@emprendiendodesdecero.com"
      },
      template_id: "f4c5ebe4-b481-4dae-9a7e-c8e93ac7bb4c"
    }

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    begin
      response = sg.client.mail._("send").post(request_body: data)
      Rails.logger.info response.status_code
      Rails.logger.info response.body
      Rails.logger.info response.headers

      if params[:individual]
        redirect_to :back, notice: 'El certificado fue creado y enviado'
      else
        redirect_to :back, notice: 'El certificado fue enviado'
      end

    rescue Exception => e
      Rails.logger.info e.message
    end
  end

=begin
  def cancel
    Sidekiq::Queue.new("critical").clear
    Sidekiq::Queue.new("medium").clear
    redirect_to unsuccessful_certificate_path(params[:job_id], name: params[:name])
  end

  def edit_batch
    add_breadcrumb "<a href='#{certificates_path(tipo: "nuevocompilado")}'>Compilado de certificados</a>".html_safe
    add_breadcrumb "<a class='active' href='#{edit_batch_certificates_path(name: params[:name], tipo: "contanciaindividual" )}'>Editar compilado</a>".html_safe
    
    return redirect_to certificates_path if Certificate.where('batch = ?', params[:name]).count == 0
  end

  def update_batch
    Certificate.where('batch = ?', params[:previous_name]).update_all(batch: params[:name])

    redirect_to certificates_path
  end

  def downloable
    unless params[:csv].blank? || params[:batch].blank? || params[:date].blank?
      certificate_template = params[:certificate_template_id]
      numrows = CSV.read(params[:csv].tempfile,  encoding: 'r:ISO-8859-15:UTF-8').size - 1
      csv_records = not_repeated_records
      repeated = numrows - csv_records.size
      how_long = distance_of_time_in_words(0, csv_records.size * 5)
      row_count = 0
      names_list = []
      job = AsyncJob.create({ total: csv_records.size, progress: 0}) 

      batch = Sidekiq::Batch.new
      batch.on(:success, CertificateWorkerDownloable, 'job_id' => job.id)
      puts batch.description = "Batch #{batch.bid}, certifaciones sin correo"
      SidekiqbatchDownloadableJob.perform_async(params[:csv], params[:batch], batch, certificate_template, job, numrows)

      redirect_to batch_certificates_path(job_id: job.id, name: params[:batch], bid: batch.bid, repeated: repeated, numrows: numrows), notice: 'Este proceso tardará ' + how_long
    else
      redirect_to certificates_path, notice: 'Verifica que los campos esten completos'
    end
  end

  def download_zip
    timestamp = Time.current.to_i
    redis = Redis.new
    redis.set("job_#{timestamp}", { total: Certificate.where('batch = ?', params[:name]).count + 1, progress: 0, url: nil}.to_json)

    CertificatesZipper.perform_async(params[:name], timestamp)

    redirect_to zip_progress_certificates_path(job_id: timestamp)
  end

  def zip_progress
  end

  def not_generated_certs
    job = AsyncJob.find(params[:job_id])
    arr_sent = YAML::load(job.started).map{|string| string.split(',')[0]}
    arr_finished = job.async_job_certificates.map{ |cert| cert.certificate.name}
    arr_missing = arr_sent - arr_finished
    sentence = arr_missing.to_sentence
    render json: sentence
  end

  def unsuccessful
    add_breadcrumb "<a href='#{certificates_path(tipo: "nuevocompilado")}'>Compilado de certificados</a>".html_safe
    add_breadcrumb "<a class='active' href='#{unsuccessful_certificate_path(params[:id], name: params[:name])}'>Certificados fallidos</a>".html_safe
    job = AsyncJob.find(params[:id])
    arr_present = YAML::load(job.started)
    arr_sent = arr_present.map{|string| string.split(',')[0]}
    arr_finished = job.async_job_certificates.map{ |cert| cert.certificate.name}
    arr_missing = arr_sent - arr_finished
    sentence = arr_missing.to_sentence
    @result = []
    arr_present.each do |sent|
      arr_missing.each do |missing|
        if sent.split(',')[0] == missing then @result << sent end
      end
    end
  end

  def not_repeated_records
    list = []
    CSV.foreach(params[:csv].tempfile, headers: true, encoding: 'r:ISO-8859-15:UTF-8') do |row|
      hash_row = {name: row['NOMBRE'], email: row['CORREO'], date: row['FECHA']}
      list << hash_row
    end
    return list.uniq
  end
=end

  private
  def certificate_params
    params.require(:certificate).permit(:name, :email, :certificate_template_id, :batch, :date)
  end

  def pdf_file
    pdf = render_to_string({
      :pdf => "certificado",
      :layout => "certificates.html",
      template: 'certificates/show',
      page_size: 'Letter',
      encoding: "utf8",
      margin:  {
        top: 0,
        bottom: 0,
        left: 0,
        right: 0
      }
    })

    temp_dir = Rails.root.join('tmp')
    Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir)
    tempfile = Tempfile.new(['certificado', '.pdf'], temp_dir)
    tempfile.binmode
    tempfile.write(pdf)
    tempfile.close

    tempfile
  end

end
