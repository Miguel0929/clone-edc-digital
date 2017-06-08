class CreateChapterStats < ActiveRecord::Migration
  def change
    create_table :chapter_stats do |t|
      t.integer :checked, default: 0
      t.references :user, index: true, foreign_key: true
      t.references :chapter, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
