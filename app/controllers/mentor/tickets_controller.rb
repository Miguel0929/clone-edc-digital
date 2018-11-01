class Mentor::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ mentor_tickets_path }'>Tickets</a>".html_safe
    @tickets = Ticket.where(coach_id: current_user.id).order(updated_at: :desc)
    if params[:filter] == "open"
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

end
