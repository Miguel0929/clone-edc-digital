class AddColumnsToUserAndProgramStat < ActiveRecord::Migration
  def up
    add_column :users, :evaluation_date, :timestamp
    add_column :users, :evaluating_mentor, :string
    add_column :program_stats, :evaluation_date, :timestamp
    add_column :program_stats, :evaluating_mentor, :string
    add_column :program_stats, :sending_method, :string
  end

  def down
  	remove_column :users, :evaluation_date, :timestamp
    remove_column :users, :evaluating_mentor, :string
    remove_column :program_stats, :evaluation_date, :timestamp
    remove_column :program_stats, :evaluating_mentor, :string
    remove_column :program_stats, :sending_method, :string
  end
end
