class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :chapter
      t.string :name
      t.integer :points

      t.string :excelent
      t.string :good
      t.string :regular
      t.string :bad
    end
  end
end
