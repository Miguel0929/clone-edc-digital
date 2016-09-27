class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.integer :user_id, index: true
      t.integer :chapter_content_id, index: true

      t.timestamps
    end
  end
end
