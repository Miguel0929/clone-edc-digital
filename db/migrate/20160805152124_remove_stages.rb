class RemoveStages < ActiveRecord::Migration
  def change
    drop_table :stages
    drop_table :stage_contents
  end
end
