class Refilable < ActiveRecord::Base
  after_destroy :destroy_ticket
  belongs_to :user
  belongs_to :template_refilable
  #has_many :evaluation_refilables
  #has_many :user_evaluation_refilables, through: :evaluation_refilables
  has_many :user_evaluation_refilables, dependent: :destroy
  
  def status
    actual = content.scan(/_____/).count
    tag = content.scan(/no-answer/).count
    (actual == 0 && tag == 0) ? "Contestado" : "Parcial";
  end

  def evaluation(user)
  	evals = self.user_evaluation_refilables.where(user_id: user.id)
  	if evals.empty?
  		return nil
  	else
  		points = 0
  		evals.each do |evaluation| points += evaluation.puntaje end
  		total_points = evals.first.evaluation_refilable.template_refilable.total_points
  		return ((points.to_f/total_points.to_f) * 100).ceil rescue 0
  	end
  end

  private

  def destroy_ticket
    template = self.template_refilable
    unless template.nil?
      if template.refilables.where(draft: false).count < 1
        ticket = Ticket.find_by(trainee_id: self.user_id, element_id: template.id, category: 1)
        ticket.destroy unless ticket.nil?
      end
    end
  end

end


