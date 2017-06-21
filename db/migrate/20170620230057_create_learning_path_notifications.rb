class CreateLearningPathNotifications < ActiveRecord::Migration
  def change
    create_table :learning_path_notifications do |t|
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
