class Refilable < ActiveRecord::Base
  belongs_to :user
  belongs_to :template_refilable

  def status
    actual = content.scan(/_____/).count

    actual == 0 ? "Contestado" : "Parcial";
  end
end
