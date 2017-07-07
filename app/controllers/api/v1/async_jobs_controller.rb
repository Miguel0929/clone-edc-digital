class Api::V1::AsyncJobsController < ApplicationController
  def show
    redis = Redis.new
    if redis.get("job_#{params[:id]}").nil?
      render json: {}, status: 404
    else
      render json: JSON.parse(redis.get("job_#{params[:id]}"))
    end
  end
end
