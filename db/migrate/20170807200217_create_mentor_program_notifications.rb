class CreateMentorProgramNotifications < ActiveRecord::Migration
  def change
    create_table :mentor_program_notifications do |t|
      t.references :program, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :notification_type

      t.timestamps null: false
    end
  end
end
