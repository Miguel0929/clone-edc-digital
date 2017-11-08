class CreateLearningPathContents < ActiveRecord::Migration
  def change
    create_table :learning_path_contents do |t|
       t.references :learning_path, index: true, foreign_key: true
      t.integer :content_id
      t.string :content_type
      t.integer :position

      t.timestamps null: false
    end
  end
end
