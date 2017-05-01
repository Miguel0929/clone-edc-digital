class CreateChapterContentRanks < ActiveRecord::Migration
  def change
    create_table :chapter_content_ranks do |t|
      t.float :rank
      t.references :user, index: true, foreign_key: true
      t.references :chapter_content, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
