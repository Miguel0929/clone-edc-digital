class CreateMentorHelps < ActiveRecord::Migration
  def change
    create_table :mentor_helps do |t|

      t.timestamps null: false
    end
  end
end
