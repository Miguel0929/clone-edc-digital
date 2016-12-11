class AddPositionToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :position, :integer
    Program.all.each do |program|
      program.chapters.order(:updated_at).each.with_index(1) do |chapter, index|
        chapter.update_column :position, index
      end
    end
  end
end
