class AddFinancieroToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :financiero, :boolean
  end
end
