class CreateRefilableNotifications < ActiveRecord::Migration
  def change
    create_table :refilable_notifications do |t|
      t.integer :template_refilable_id, index: true
      t.integer :notification_type
      t.timestamps null: false
    end
  end
end
