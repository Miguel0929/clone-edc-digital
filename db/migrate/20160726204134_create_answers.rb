class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :user_id, index: true
      t.integer :question_id, index: true

      t.text :answer_text, index: true
    end
  end
end
