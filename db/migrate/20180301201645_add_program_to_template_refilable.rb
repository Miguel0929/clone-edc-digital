class AddProgramToTemplateRefilable < ActiveRecord::Migration
  def change
    add_reference :template_refilables, :program, index: true, foreign_key: true
  end
end
