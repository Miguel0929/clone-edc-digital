class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name
      t.integer :chapter_id, index: true

      t.timestamps
    end
  end
end
