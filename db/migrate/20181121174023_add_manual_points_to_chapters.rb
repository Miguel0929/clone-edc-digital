class AddManualPointsToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :manual_points, :boolean, :default => false
  end
end
