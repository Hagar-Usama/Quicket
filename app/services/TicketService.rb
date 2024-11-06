
class TicketService
    include HTTParty
    base_uri "https://api.tito.io/v3/hagar-usama/delta-spectres"
    def self.fetch_and_create_tickets(user)
      Rails.logger.error("[TicketService] fetching tickets ...")
      # debugger

      token = Rails.application.credentials.dig(:api, :token)
      response = get("/tickets", headers: { "Authorization" => "Token token=#{token}" })
      # debugger
      if response.success?
        Rails.logger.info("Successfully fetched tickets: #{response.parsed_response['tickets'].size} tickets found.")
        tickets = response.parsed_response["tickets"]
        tickets.each do |ticket_data|
          create_ticket(ticket_data, user.id)
        end
      else
        Rails.logger.error("[TicketService] Failed to fetch tickets: #{response.code} - #{response.message}")
      end
    end

    def self.create_ticket(ticket_data, user_id)
      ticket = Ticket.find_or_initialize_by(id: ticket_data["id"]) do |t|
        t.user_id = user_id
      end

      ticket.email = ticket_data["email"]
      ticket.first_name = ticket_data["first_name"]
      ticket.last_name = ticket_data["last_name"]
      ticket.name = ticket_data["name"]
      ticket.phone_number = ticket_data["phone_number"]
      ticket.state = ticket_data["state"]

      if ticket.save
        Rails.logger.info("[TicketService] Successfully created/updated ticket for #{ticket.name} (#{ticket.email})")
      else
        Rails.logger.error("[TicketService] Failed to create/update ticket for #{ticket.name}: #{ticket.errors.full_messages.join(", ")}")
      end
    end
end
