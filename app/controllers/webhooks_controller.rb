class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token # Skip CSRF verification for webhooks
  skip_before_action :authenticate_user!, only: [ :tito ]

  def tito
    payload = JSON.parse(request.body.read)

    Rails.logger.info("Received Tito webhook: #{payload}")

    # Verify the HMAC signature
    if valid_signature?(request.headers["Tito-Signature"], request.body.read)
      if payload["_type"] == "ticket"
        # debugger
        # fetch users whose email matches the ticket's email
        TicketService.save_ticket(payload)
        ActionCable.server.broadcast("webhook_updates", { message: "Data refreshed!", payload: payload })

      end

      head :ok
    else
      Rails.logger.error("Invalid signature for the incoming webhook.")
      head :unauthorized
    end
  rescue => e
    Rails.logger.error("Error processing Tito webhook: #{e.message}")
    head :unprocessable_entity
  end


  private


  def valid_signature?(tito_signature, raw_payload)
    # key = Rails.application.credentials.dig(:tito, :webhook_secret) # Get your security token from credentials
    key = ENV("TITO_WEBHOOK_SECRET")
    hash = OpenSSL::Digest.new("sha256")
    expected_signature = Base64.encode64(OpenSSL::HMAC.digest(hash, key, raw_payload)).strip
    ActiveSupport::SecurityUtils.secure_compare(expected_signature, tito_signature)
  end
end
