class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :name
      t.integer :program_id, index: true

      t.timestamps
    end
  end
end
