class AddPositionToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :position, :integer
  end
end
