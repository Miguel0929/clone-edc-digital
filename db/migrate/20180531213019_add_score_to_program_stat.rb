class AddScoreToProgramStat < ActiveRecord::Migration
  def up
  	add_column :program_stats, :score, :float, :default => 0
  	change_column :program_stats, :program_progress, :float, default: 0
  	change_column :program_stats, :program_seen, :float, default: 0
  end

  def down
  	remove_column :program_stats, :score
  	change_column :program_stats, :program_progress, :float, default: nil
  	change_column :program_stats, :program_seen, :float, default: nil
  end
end
