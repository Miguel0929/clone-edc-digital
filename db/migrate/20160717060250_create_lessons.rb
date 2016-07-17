class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :identifier
      t.text :content
      t.timestamps
    end
  end
end
