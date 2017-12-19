class AddTipoToTemplateRefilable < ActiveRecord::Migration
  def change
    add_column :template_refilables, :tipo, :integer
  end
end
