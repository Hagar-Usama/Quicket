
class TicketService
    include HTTParty
    # base_uri "https://api.tito.io/v3/hagar-usama/delta-spectres"
    base_uri "#{ENV['TITO_API_BASE']}/#{ENV['TITO_ACCOUNT_SLUG']}/#{ENV['TITO_EVENT_SLUG']}"


    def self.fetch_and_save_tickets
      Rails.logger.error("[TicketService] fetching tickets ...")

      token = Rails.application.credentials.dig(:api, :token)
      page = 1
      per_page = 100

      loop do
        response = get("/tickets?page[number]=#{page}&page[size]=#{per_page}",
                       headers: { "Authorization" => "Token token=#{token}" })

        # rate limit check
        if response.code == 429
          retry_after = response.headers["Retry-After"].to_i
          retry_after = retry_after.zero? ? 10 : retry_after

          Rails.logger.warn("[TicketService] Rate limited. Retrying after #{retry_after} seconds...")
          sleep(retry_after)
          next

        # Check if request was successful
        elsif response.success?
          tickets = response.parsed_response["tickets"]
          Rails.logger.info("Page #{page} - Fetched #{tickets.size} tickets.")

          # Save the tickets
          tickets.each do |ticket_data|
            save_ticket(ticket_data)
          end

          # Check if there is a next page
          meta = response.parsed_response["meta"]
          next_page = meta["next_page"]

          break unless next_page
          page += 1

        else
          Rails.logger.error("[TicketService] Failed to fetch tickets: #{response.code} - #{response.message}")
          break
        end
      end
    end


    def self.ticket_exists?(email)
      token = Rails.application.credentials.dig(:api, :token)
      response = get("/tickets", headers: { "Authorization" => "Token token=#{token}" }, query: { "search[emails][]" => email })
      if response.success?
        data = response.parsed_response

        # Check if tickets exist in the response
        tickets = data["tickets"]
        if tickets && tickets.any?
          { exists: true }
        else
          { exists: false }
        end
      else
        Rails.logger.error("TicketService Error: #{response.message}")
        { exists: false }
      end
    end

    def self.save_ticket(ticket_data)
      user = User.find_by(email: ticket_data["email"])
      ticket = Ticket.unscoped.find_by(id: ticket_data["id"])
      return if ticket && ticket.deleted_at.present? # Skip deleted tickets
      ticket ||= Ticket.new(id: ticket_data["id"])
      ticket.user_id = user.id if user

      ticket.assign_attributes(
        email: ticket_data["email"],
        first_name: ticket_data["first_name"],
        last_name: ticket_data["last_name"],
        name: ticket_data["name"],
        phone_number: ticket_data["phone_number"],
        state: ticket_data["state"]
      )

      if ticket.save
        Rails.logger.info("[TicketService] Successfully created/updated ticket for #{ticket.name} (#{ticket.email})")
      else
        Rails.logger.error("[TicketService] Failed to create/update ticket for #{ticket.name}: #{ticket.errors.full_messages.join(", ")}")
      end
    end
end
