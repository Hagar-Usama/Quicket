require "rufus-scheduler"

scheduler = Rufus::Scheduler.new

scheduler.every "1h" do
  Rails.logger.info("[Scheduler] Starting Fetching tickets ...")
  TicketService.fetch_and_save_tickets
end
