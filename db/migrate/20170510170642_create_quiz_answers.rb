class CreateQuizAnswers < ActiveRecord::Migration
  def change
    create_table :quiz_answers do |t|
      t.references :user, index: true, foreign_key: true
      t.references :quiz_question, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
