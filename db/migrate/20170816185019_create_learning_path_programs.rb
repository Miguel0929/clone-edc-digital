class CreateLearningPathPrograms < ActiveRecord::Migration
  def change
    create_table :learning_path_programs do |t|
      t.references :program, index: true, foreign_key: true
      t.references :learning_path, index: true, foreign_key: true
      t.integer :position

      t.timestamps null: false
    end
  end
end
