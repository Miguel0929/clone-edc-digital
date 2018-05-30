class Refilable < ActiveRecord::Base
  belongs_to :user
  belongs_to :template_refilable
  #has_many :evaluation_refilables
  #has_many :user_evaluation_refilables, through: :evaluation_refilables
  def status
    actual = content.scan(/_____/).count
    tag = content.scan(/no-answer/).count
    (actual == 0 && tag == 0) ? "Contestado" : "Parcial";
  end
end