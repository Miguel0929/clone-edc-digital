class CreateAttempts < ActiveRecord::Migration
  def change
    create_table :attempts do |t|
      t.references :quiz, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
