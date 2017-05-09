class CreateRating < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.float :rank
      t.references :user, index: true, foreign_key: true
      t.references :ratingable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
