class CreateUserCodes < ActiveRecord::Migration
  def change
    create_table :user_codes do |t|
      t.string :codigo
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
