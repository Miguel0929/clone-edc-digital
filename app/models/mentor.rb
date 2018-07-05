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
end
