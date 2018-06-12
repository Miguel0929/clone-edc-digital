class TicketsController < ApplicationController

  def switch
    element = params[:element_id].to_i
    category = params[:category].to_i
    ticket = Ticket.find_by(element_id: element, category: category)

    if ticket.closed
      ticket.update(closed: false)
    else
      ticket.update(closed: true)
    end

    respond_to do |format|
      format.json { render :json => {status: "ok"} }
    end
  end

  def generate_ticket
    element = params[:element_id].to_i
    trainee = params[:trainee_id].to_i
    coach = params[:coach_id].to_i
    category = params[:category].to_i
    ticket = Ticket.find_by(element_id: element, category: category)
    
    if category == 0
      title = "Nuevo mensaje de alumno: " + (Mailboxer::Conversation.find(element).subject)
    end

    if ticket.nil?
      Ticket.create(element_id: element, trainee_id: trainee, coach_id: coach, category: category, title: title)
    end

    respond_to do |format|
      format.json { render :json => {status: "ok"} }
    end
  end

end