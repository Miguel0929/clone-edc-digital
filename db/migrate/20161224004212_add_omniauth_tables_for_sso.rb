class AddOmniauthTablesForSso < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    create_table :access_grants do |t|
      t.string :code
      t.string :access_token
      t.string :refresh_token
      t.datetime :access_token_expires_at
      t.integer :user_id
      t.integer :client_id
      t.string :state

      t.timestamps
    end

    create_table :clients do |t|
      t.string :name
      t.string :app_id
      t.string :app_secret

      t.timestamps
    end
  end
end
