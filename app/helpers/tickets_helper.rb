module TicketsHelper

	def create_ticket(user, element)

		coach = nil
		category = element.class.name

		if !user.coach.nil?
			coach = user.coach
		elsif !user.group.nil?
			chosen = choose_ticket_mentor(user.group)
			coach = chosen.nil? ? nil : User.find(chosen)
		end	

		unless coach.nil?
			case category
			when "Refilable"
				Ticket.create(coach_id: coach.id, trainee_id: user.id, element_id: element.template_refilable.id, category: 1, title: "Nueva respuesta de plantilla: " + element.template_refilable.name)
			when "Mailboxer::Conversation"
				Ticket.create(coach_id: coach.id, trainee_id: user.id, element_id: element.id, category: 0, title: "Nuevo mensaje de alumno: " + element.subject)
			end
		end
	end

	def choose_ticket_mentor(group)
		mentors = group.users.where(role: 1)
		if mentors.count > 0
			numbers = []
			mentors.each do |mentor|
				numbers.push({ mentor_id: mentor.id, tickets_count: Ticket.where(coach_id: mentor.id, closed: false).count })
			end
			return numbers.sort_by { |num| num[:tickets_count]}.first[:mentor_id]
		else
			return nil
		end
	end

	def close_ticket(trainee, element)
		category = element.class.name
		case category
		when "TemplateRefilable"
			ticket = Ticket.find_by(trainee_id: trainee.id, category: 1, element_id: element.id)
			ticket.update(closed: true) unless ticket.nil?
		when "Mailboxer::Conversation"
			ticket = Ticket.find_by(trainee_id: trainee.id, category: 0, element_id: element.id)
			ticket.update(closed: true) unless ticket.nil?
		end
	end

	def open_ticket(trainee, element)
		category = element.class.name
		case category
		when "TemplateRefilable"
			ticket = Ticket.find_by(trainee_id: trainee.id, category: 1, element_id: element.id)
			ticket.update(closed: false) unless ticket.nil?
		when "Mailboxer::Conversation"
			ticket = Ticket.find_by(trainee_id: trainee.id, category: 0, element_id: element.id)
			ticket.update(closed: false) unless ticket.nil?
		end
	end

	def get_student_ticket(trainee, element)
		category = element.class.name
		case category
		when "TemplateRefilable"
			return Ticket.find_by(trainee_id: trainee.id, category: 1, element_id: element.id)
		when "Mailboxer::Conversation"
			return Ticket.find_by(trainee_id: trainee.id, category: 0, element_id: element.id)
		end
	end

end