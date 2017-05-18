class Api::V1::AsyncJobsController < ApplicationController
  def show
    @job = AsyncJob.find(params[:id])
    render json: @job
  end
end
