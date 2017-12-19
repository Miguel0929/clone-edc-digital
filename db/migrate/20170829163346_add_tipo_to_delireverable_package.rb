class AddTipoToDelireverablePackage < ActiveRecord::Migration
  def change
  	add_column :delireverable_packages, :tipo, :integer
  end
end
