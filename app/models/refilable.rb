class Refilable < ActiveRecord::Base
  belongs_to :user
  belongs_to :template_refilable

  def status
    actual = content.scan(/_____/).count
    tag = content.scan(/no-answer/).count
    (actual == 0 && tag == 0) ? "Contestado" : "Parcial";
  end
end