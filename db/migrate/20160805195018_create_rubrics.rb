class CreateRubrics < ActiveRecord::Migration
  def change
    create_table :rubrics do |t|
      t.string :criteria
      t.text :base

      t.integer :question_id, index: true
    end
  end
end
