class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :universities do |t|
      t.string :name
      t.references :state, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
