class Dashboard::StageContentsController < ApplicationController
  def show
    @stage_content = StageContent.find(params[:id])
  end
end
