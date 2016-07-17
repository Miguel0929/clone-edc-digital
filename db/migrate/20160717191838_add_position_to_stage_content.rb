class AddPositionToStageContent < ActiveRecord::Migration
  def change
    add_column :stage_contents, :position, :integer
  end
end
