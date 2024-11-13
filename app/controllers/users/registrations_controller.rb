# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  after_action :perform_post_registration_tasks, only: [ :create ]

  # POST /resource
  def create
    email = sign_up_params[:email]
    ticket_service_response = TicketService.ticket_exists?(email)

    if ticket_service_response[:exists]
      tickets = Ticket.where(email: email)
      if tickets.any?
        ActiveRecord::Base.transaction do
          # Save the new user only if local tickets are present
          super do |user|
            if user.persisted?
              user.tickets << tickets

              first_ticket = tickets.first
              user.name = first_ticket.name if first_ticket&.name

              Rails.logger.info("User #{user.id} created and assigned #{tickets.size} tickets.")

              # Display success message
              flash[:notice] = "User #{user.id} successfully signed in with #{tickets.size} tickets."
              user.save!
            else
              Rails.logger.warn("Failed to create user for email: #{email}.")
              raise ActiveRecord::Rollback
            end
          end
        end
      else
        redirect_to new_user_registration_path, alert: "No local tickets found with this email. Please contact support or use a different email."
        Rails.logger.warn("User registration attempt with no local tickets found for email: #{email}")
      end
    else
      redirect_to new_user_registration_path, alert: "No tickets found with this email. Please contact support or use a different email."
      Rails.logger.warn("User registration attempt with no external tickets found for email: #{email}")
    end
  end


  # Define permitted parameters for sign up
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def perform_post_registration_tasks
    Rails.logger.info("[Registration Controller], fetching tickets")
    TicketService.fetch_and_save_tickets
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
