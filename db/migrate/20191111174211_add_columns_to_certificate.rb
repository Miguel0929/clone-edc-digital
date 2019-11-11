class AddColumnsToCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :program, :string
    add_column :certificates, :route, :string
  end
end
