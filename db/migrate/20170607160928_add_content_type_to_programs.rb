class AddContentTypeToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :content_type, :string
  end
end
