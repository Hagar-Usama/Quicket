# config/initializers/scheduler.rb
require "#{Rails.root}/app/services/ticket_service"
require "rufus-scheduler"

scheduler = Rufus::Scheduler.new

# Run once immediately after the server starts
scheduler.at(Time.now) do
  Rails.logger.info("[Scheduler] Running migrations...")
  success = system("rails db:migrate")
  
  if success
    Rails.logger.info("[Scheduler] Migrations completed successfully.")
    TicketService.fetch_and_save_tickets      
  else
    Rails.logger.error("[Scheduler] Migrations failed.")
  end
end


# scheduler.at(Time.now + 20) do
#   Rails.logger.info("[Scheduler] Fetching tickets on server start...")
#    # Running migrations with the system command
#    system("rails db:migrate")
#    system("rails db:seed")
#   TicketService.fetch_and_save_tickets
# end

# Run every 1 hour after the server starts
scheduler.every '1h' do
  Rails.logger.info("[Scheduler] Fetching tickets every hour...")
  TicketService.fetch_and_save_tickets
end
