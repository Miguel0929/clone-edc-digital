class AddColumnsToUser < ActiveRecord::Migration
  def up
    add_column :users, :user_progress, :float, default: 0.0
    add_column :users, :user_seen, :float, default: 0.0
  end

  def down
    remove_column :users, :user_progress
    remove_column :users, :user_seen
  end
end
