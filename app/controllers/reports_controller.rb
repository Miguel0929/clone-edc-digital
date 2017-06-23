class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [:index,:destroy,:visto]
  before_action :set_report, only: [:destroy, :visto]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{reports_path}'>Reportes de contenido</a>".html_safe
  	@reports=Report.order(:created_at).page(params[:page]).per(20)
  end 
  def create
  	@chapter_content=ChapterContent.find(params[:chapter_content_id])
  	@chapter_content.reports.create(cause: params[:cause], status: true, user_id: current_user.id)
    report = @chapter_content.reports.order(:created_at).last
    rn=ReportNotification.create(report_id: report.id)
    User.admin.each do |usr|
      Notification.create(user_id: usr.id, notificable: rn)
    end  
    Reports.report(report)
  	render json: {status: "Ok"}
  end
  def destroy
  	@report.delete
  	redirect_to  reports_path
  end
  def visto
  	@report.status=!@report.status
  	@report.save
  	redirect_to  reports_path
  end

  private
  	def set_report
  		@report=Report.find(params[:id])
  	end	
end