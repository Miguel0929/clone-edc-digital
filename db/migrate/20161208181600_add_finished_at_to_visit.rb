class AddFinishedAtToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :finished_at, :datetime
  end
end
