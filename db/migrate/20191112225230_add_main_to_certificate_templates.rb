class AddMainToCertificateTemplates < ActiveRecord::Migration
  def change
    add_column :certificate_templates, :main, :boolean, :default => false
  end
end
