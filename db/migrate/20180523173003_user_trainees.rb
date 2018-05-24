class UserTrainees < ActiveRecord::Migration
  
  def up
    create_table :user_trainees do |t|
      t.integer :user_id
      t.integer :trainee_id
      t.timestamps null: false
    end
    add_column :users, :coach_id, :integer

    add_foreign_key :user_trainees, :users, :column => "user_id", primary_key: :id
	add_foreign_key :user_trainees, :users, :column => "trainee_id", primary_key: :id
	add_foreign_key :users, :users, :column => "coach_id", primary_key: :id
  end

  def down
  	remove_foreign_key "user_trainees", :column => "user_id"
  	remove_foreign_key "user_trainees", :column => "trainee_id"
  	drop_table :user_trainees
  	remove_foreign_key "users", :column => "coach_id"
  	remove_column :users, :coach_id, :integer
  end

end
