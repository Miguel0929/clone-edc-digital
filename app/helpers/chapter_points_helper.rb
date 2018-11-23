module ChapterPointsHelper

	def check_max_points(program, chapter, input_points)
    unvalued_chapters = program.chapters.where(manual_points: false).includes(:chapter_contents).where(chapter_contents: {coursable_type: "Question"})
    valuated_chapters_points = program.chapters.where(manual_points: true).pluck(:points).inject(0){|sum,x| sum + x }
    if chapter.nil?
      if !input_points.empty?
        render :json => { "status" => ((input_points.to_i + valuated_chapters_points + unvalued_chapters.count) <= 100) }
      else
        render :json => { "status" => ((valuated_chapters_points + unvalued_chapters.count + 1) <= 100) }
      end
    else
      if chapter.manual_points
        valuated_chapters_points = valuated_chapters_points - chapter.points       
      end
      render :json => { "status" => ((input_points.to_i + valuated_chapters_points + unvalued_chapters.count) <= 100) }
    end
	end

end