class ChangeProgramsContentType < ActiveRecord::Migration
  def up
    change_column :programs, :content_type, "integer USING CAST(content_type AS integer)"
  end
 
  def down
    change_column :programs, :content_type, "string USING CAST(content_type AS string)"
  end
end
