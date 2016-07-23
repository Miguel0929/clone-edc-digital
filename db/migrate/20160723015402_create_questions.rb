class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer  :question_type, default: 0
      t.string  :question_text
      t.integer :position
      t.text :answer_options

      t.timestamps
    end
  end
end
