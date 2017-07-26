class CreateQueueNotifications < ActiveRecord::Migration
  def up
    create_table :queue_notifications do |t|
      t.integer :category
      t.integer :program
      t.text :groups
      t.string :url
      t.string :detail
      t.boolean :sent, default: false
    end
  end

  def down
  	drop_table :queue_notifications
  end
end
