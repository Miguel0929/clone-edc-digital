class AddAditionalInformationToUser < ActiveRecord::Migration
  def change
    add_column :users, :bio, :text
    add_column :users, :gender, :integer
    add_column :users, :state, :string
    add_column :users, :city, :string
    add_column :users, :profile_picture, :string
  end
end
