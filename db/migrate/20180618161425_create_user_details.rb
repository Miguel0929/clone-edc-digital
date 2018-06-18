class CreateUserDetails < ActiveRecord::Migration
  def up
    create_table :user_details do |t|
      t.references :user, index: true, foreign_key: true
      t.date :birthdate
      t.string :situation
      t.string :interest
      t.text :challenge
      t.text :goal
      t.timestamps null: false
    end
  end

  def down
    drop_table :user_details
  end
end
