class Mentor < User
  default_scope { mentors }

  def linked_students
  	linked = 0
  	linked += self.trainees.invitation_accepted.where("user_seen > 0").count	
  end

  def linked_students_state(state)
  	linked = 0
  	linked += self.trainees.invitation_accepted.joins(:group).where("groups.state_id = ? and users.user_seen > 0", state.id).count
  end

  def linked_students_state_zz(state)
  	linked = 0
  	linked += self.trainees.invitation_accepted.joins(:group).where("groups.state_id = ? and users.user_seen = 0", state.id).count
  end

  def seguimiento_tickets(programs, day)
    ids = []
    programs.each do |program|
      p program.template_refilables.pluck(:id)
      ids += program.template_refilables.pluck(:id)
    end 
    Ticket.where(element_id: ids, coach_id: self, closed: true, updated_at: day.beginning_of_day..day.end_of_day, category: 1).count
  end  
end
