class CreatePanelNotifications < ActiveRecord::Migration
  def change
    create_table :panel_notifications do |t|
      t.integer :notification
      t.references :user, index: true, foreign_key: true
      t.boolean :status
      t.timestamps null: false
    end
  end
end
