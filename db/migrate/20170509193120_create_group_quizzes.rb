class CreateGroupQuizzes < ActiveRecord::Migration
  def change
    create_table :group_quizzes do |t|
      t.references :group, index: true, foreign_key: true
      t.references :quiz, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
