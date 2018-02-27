class CreateUserTrackers < ActiveRecord::Migration
  def change
    create_table :user_trackers do |t|
    	t.integer :old_group
    	t.integer :user_id
    	t.string :action
      t.timestamps null: false
    end
  end
end
