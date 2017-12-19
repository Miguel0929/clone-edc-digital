class CreateLearningPaths < ActiveRecord::Migration
  def change
    create_table :learning_paths do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
