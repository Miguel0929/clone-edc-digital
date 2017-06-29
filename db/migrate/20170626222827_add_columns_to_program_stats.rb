class AddColumnsToProgramStats < ActiveRecord::Migration
  def change
    add_column :program_stats, :program_progress, :float
    add_column :program_stats, :program_seen, :float
  end
end
