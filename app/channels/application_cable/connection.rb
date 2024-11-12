module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      Rails.logger.info "[Connection] WebSocket connection initiated"
      self.current_user = find_verified_user
      Rails.logger.info "User connected: #{current_user.id}"
    end

    private

    def find_verified_user
      # Your user verification logic here
    end
  end
end
