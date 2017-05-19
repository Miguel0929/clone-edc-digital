class CreateQuizQuestions < ActiveRecord::Migration
  def change
    create_table :quiz_questions do |t|
      t.integer :question_type
      t.string :question_text
      t.integer :position
      t.text :answer_options
      t.text :support_text
      t.integer :points
      t.references :quiz, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
