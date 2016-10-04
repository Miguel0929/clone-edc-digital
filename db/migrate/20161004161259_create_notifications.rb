class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id, index: true
      t.integer :notificable_id
      t.string  :notificable_type
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
