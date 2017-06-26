class CreateGroupStats < ActiveRecord::Migration
  def change
    create_table :group_stats do |t|
      t.integer :group_students
      t.float :average_progress
      t.float :average_seen
      t.integer :evaluated_students
      t.integer :unevaluated_studets
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
