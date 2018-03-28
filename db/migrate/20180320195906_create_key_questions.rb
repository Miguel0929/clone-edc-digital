class CreateKeyQuestions < ActiveRecord::Migration
  def up
    create_table :key_questions do |t|
      t.integer :coursable_id
      t.references :chapter_content, index: true, foreign_key: true
      t.timestamps null: false
    end
  end

  def down
  	drop_table :key_questions
  end
end
