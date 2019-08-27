class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:switch, :generate_ticket]
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ tickets_path }'>Tickets</a>".html_safe
    @tickets = Ticket.all.order(updated_at: :desc)
    if params[:filter] == "open"
      puts "open we"
      @tickets = @tickets.where(closed: false)
    elsif params[:filter] == "closed"
      @tickets = @tickets.where(closed: true)
    end 
    if params[:query].present?
      users = User.where("email ILIKE ? OR lower(first_name) = ? OR lower(last_name) = ?", params[:query].to_s + "%", params[:query].downcase, params[:query].downcase).pluck(:id)
      arry = "ARRAY" + users.to_s
      @tickets = @tickets.where("coach_id = ANY (" + arry + ") or trainee_id = ANY (" + arry + ")")
    end
    @tickets = @tickets.page(params[:page]).per(50)
  end

  def switch
    element = params[:element_id].to_i
    category = params[:category].to_i
    ticket = Ticket.find_by(element_id: element, category: category)
    puts ("id", element)
    puts ("category", category)
    puts ("ticket", ticket)
    puts ("ticket2", Ticket.find_by(element_id: element))

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