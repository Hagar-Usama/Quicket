# class ApplicationController < ActionController::Base
#   # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
#   allow_browser versions: :modern
# end

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protected

  def after_sign_in_path_for(resource)
    # Fetch and create tickets after sign-in
    # debugger
    # TicketService.fetch_and_create_tickets(resource)
  end

  def after_sign_in_path_for(resource)
    flash[:role_notice] = "You are signed in as #{resource.role.humanize}."
    tickets_path
  end
end
