class WebhookProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 2

  def perform(event_id)
    event = WebhookEvent.find_by(id: event_id)
    return unless event

    Pinpoint::ApplicationHiredHibobService.new(event).call
  rescue StandardError => e
    event.update(status: "failed", error_message: e.message)
    raise e
  end
end
