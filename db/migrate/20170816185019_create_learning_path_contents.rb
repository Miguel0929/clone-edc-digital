class CreateLearningPathContents < ActiveRecord::Migration
  def change
    create_table :learning_path_contents do |t|
      t.references :content, :polymorphic => true
      t.references :learning_path, index: true, foreign_key: true
      t.integer :position

      t.timestamps null: false
    end
  end
end
