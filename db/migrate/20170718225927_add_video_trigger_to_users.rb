class AddVideoTriggerToUsers < ActiveRecord::Migration
  def up
    add_column :users, :video_trigger, :boolean, default: true
  end

  def down
  	remove_column :users, :video_trigger
  end
end
