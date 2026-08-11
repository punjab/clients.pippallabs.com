require "net/http"
require "net/smtp"

class LeadAlertJob < ApplicationJob
  queue_as :default

  retry_on Net::SMTPServerBusy, Net::ReadTimeout, wait: :polynomially_longer, attempts: 5

  def perform(notification)
    return unless notification.status_pending? || notification.status_failed?

    notification.update!(attempts: notification.attempts + 1, last_attempted_at: Time.current)
    delivery = LeadMailer.with(notification:).new_lead.deliver_now
    notification.update!(status: :delivered, provider_message_id: delivery.message_id, last_error: nil)
  rescue StandardError => error
    notification.update!(status: :failed, last_error: error.message.to_s.first(1_000))
    raise
  end
end
