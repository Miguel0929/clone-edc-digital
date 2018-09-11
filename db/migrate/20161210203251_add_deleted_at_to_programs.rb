class AddDeletedAtToPrograms < ActiveRecord::Migration
  def change
  	unless column_exists? :programs, :deleted_at
	  	add_column :programs, :deleted_at, :datetime
	    add_index :programs, :deleted_at
	end
  end
end
