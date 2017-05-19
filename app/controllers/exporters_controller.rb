class ExportersController < ApplicationController
  def show
    @job_id = params[:id]
  end
end
