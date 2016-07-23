class StageContentsController < ApplicationController
  def sort
    params[:stage_content].each_with_index do |id, index|
      StageContent.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
  end
end
