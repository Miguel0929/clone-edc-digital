class Dashboard::StageContentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @stage_content = StageContent.find(params[:id])

    if @stage_content.coursable_type == 'Question'
      redirect_to new_dashboard_stage_content_answer_path(@stage_content)
    end
  end

end
