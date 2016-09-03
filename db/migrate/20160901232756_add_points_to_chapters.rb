class AddPointsToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :points, :integer
  end
end
