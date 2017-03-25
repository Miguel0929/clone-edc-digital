class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :user
      t.string :browser
      t.string :platform
      t.string :device_type
      t.datetime :start
      t.datetime :finish
    end
  end
end
