class CreateRubricNotification < ActiveRecord::Migration
  def change
    create_table :program_notifications do |t|
      t.integer :program_id, index: true
      t.integer :notification_type
    end
  end
end
