# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    email = sign_up_params[:email]
    # Call the TicketService to check for an external ticket
    ticket_service_response = TicketService.ticket_exists?(email)

    if ticket_service_response[:exists]
      # bring all local tickets to user and assign it to the user
      tickets = Ticket.where(email: email)
      if tickets.any?
        ActiveRecord::Base.transaction do
          super do |user|
            # Attach all tickets to the new user
            user.tickets << tickets
            if user.valid?
              user.save!
              Rails.logger.info("Successfully attached #{tickets.size} tickets to user #{user.id}")
              # render a message
              flash[:notice] = "Successfully user #{user.id} signed in"
            else
              raise ActiveRecord::Rollback, "User creation failed, tickets not attached"
            end
          end
        end
      else
        # If no tickets are found, redirect with an error message
        redirect_to new_user_registration_path, alert: "No tickets found with this email. Please contact support or use a different email."
      end
    end
  end



  # def create
  #   email = sign_up_params[:email]

  #   # Find the ticket by email (this is done directly in the controller, no API calls)
  #   ticket = Ticket.find_by(email: email)

  #   if ticket
  #     super do |user|
  #       # user.id = ticket.user_id
  #       user.save if user.valid?
  #     end
  #   else
  #     # If no ticket is found, redirect with an error message
  #     redirect_to new_user_registration_path, alert: "No ticket found with this email. Please contact support or use a different email."
  #   end
  # end

  private

  # Define permitted parameters for sign up
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
