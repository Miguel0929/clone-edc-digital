class AddLastContentToProgramStats < ActiveRecord::Migration
  def up
    add_column :program_stats, :last_content, :integer
  end

  def down
  	remove_column :program_stats, :last_content, :integer
  end
end
