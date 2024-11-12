class WebhookUpdatesChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "[WebhookUpdatesChannel] Subscribed to WebhookUpdatesChannel"
    stream_from "webhook_updates"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
