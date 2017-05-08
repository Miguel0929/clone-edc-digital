class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [:index,:destroy,:visto]
  before_action :set_report, only: [:destroy, :visto]
  def index
  	@reports=Report.order(:created_at).page(params[:page]).per(20)
  end 
  def create
  	@chapter_content=ChapterContent.find(params[:chapter_content_id])
  	@chapter_content.reports.create(cause: params[:cause],status: true)
    Reports.report(@chapter_content.reports.first)
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
