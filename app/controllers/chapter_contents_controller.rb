class ChapterContentsController < ApplicationController
  def sort
    params[:chapter_content].each_with_index do |id, index|
      ChapterContent.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
  end
end
