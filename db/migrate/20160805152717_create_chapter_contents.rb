class CreateChapterContents < ActiveRecord::Migration
  def change
    create_table :chapter_contents do |t|
      t.integer :chapter_id
      t.integer :coursable_id
      t.string  :coursable_type
      t.integer :position
    end
  end
end
