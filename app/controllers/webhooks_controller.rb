class WebhooksController < ApplicationController
  def pinpoint
    return head :unauthorized unless Pinpoint::VerifyWebhook.new(request).call

    payload = JSON.parse(request.raw_post)
    event = WebhookEvent.create!(
      source: "pinpoint",
      headers: request.headers.env.select { |k, _| k.start_with?("HTTP_") },
      payload: payload,
      status: "pending"
    )

    WebhookProcessingJob.perform_later(event.id)
    head :ok
  end
end
