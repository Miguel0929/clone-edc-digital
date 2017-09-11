class AddCheckReadyToUsers < ActiveRecord::Migration
  def up
    add_column :users, :check_ready, :boolean
  end

  def down
    remove_column :users, :check_ready, :boolean
  end
end
