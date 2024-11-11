class TicketsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :ticket_exists? ]
  before_action :authenticate_user!
  before_action :set_ticket, only: [ :show, :update, :soft_delete ]


  ITEMS_PER_PAGE = 12
  def ticket_exists?
    email = params[:email]
    exists = Ticket.exists?(email: email)
    render json: { exists: exists }
  end

  def index
    if current_user.admin?
      # Admins see all tickets, even those marked as deleted
      # @tickets = Ticket.all
      @tickets = Ticket.page(params[:page]).per(ITEMS_PER_PAGE)
    else
      # Regular users see only their non-deleted tickets
      # @tickets = current_user.tickets.where(deleted_at: nil).page(params[:page]).per(ITEMS_PER_PAGE)
      @tickets = current_user.tickets.page(params[:page]).per(ITEMS_PER_PAGE)

    end
  end

  def show
  end

  def update
    if @ticket.update(deleted_at: Time.current)
      flash[:notice] = "Ticket successfully marked as deleted."
      redirect_to tickets_path
    else
      flash[:alert] = "Failed to mark ticket as deleted."
      render :show
    end
  end

  def soft_delete
    if @ticket.update(deleted_at: Time.current)
      flash[:notice] = "Ticket successfully marked as deleted."
      # flash[:notice] = "Ticket has been successfully created."
      # flash[:alert] = "An error occurred while creating the ticket."
      # flash[:error] = "Ticket could not be found."
      # flash[:success] = "Action was successful!"
      redirect_to tickets_path
    else
      flash[:alert] = "Failed to mark ticket as deleted."
      render :show
    end
  end

  def fetch_tickets
    TicketService.fetch_and_save_tickets(current_user)
    redirect_to tickets_path, notice: "Tickets fetched successfully."
  end

  private

  def set_ticket
    if current_user.admin?
      @ticket = Ticket.find(params[:id]) # Admin can access any ticket
    else
      @ticket = current_user.tickets.find(params[:id]) # Regular users can only access their own tickets
    end
  end

  def ticket_params
    params.require(:ticket).permit(:email, :first_name, :last_name, :name, :phone_number, :state)
  end
end
