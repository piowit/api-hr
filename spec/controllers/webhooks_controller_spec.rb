require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST #pinpoint' do
    it 'handles a webhook payload successfully when application_hired event is received' do
      verify_webhook_instance = instance_double("Pinpoint::VerifyWebhook")
      allow(Pinpoint::VerifyWebhook).to receive(:new).and_return(verify_webhook_instance)
      allow(verify_webhook_instance).to receive(:call).and_return(true)

      payload = {
        event: "application_hired",
        triggered_at: 1614687278,
        data: {
          application: {
            id: 8863860
          },
          job: {
            id: 1
          }
        }
      }

      post :pinpoint, params: payload, as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized when webhook verification fails' do
      verify_webhook_instance = instance_double("Pinpoint::VerifyWebhook")
      allow(Pinpoint::VerifyWebhook).to receive(:new).and_return(verify_webhook_instance)
      allow(verify_webhook_instance).to receive(:call).and_return(false)

      payload = {
        event: "application_hired",
        triggered_at: 1614687278,
        data: {
          application: { id: 8863860 },
          job: { id: 1 }
        }
      }

      post :pinpoint, params: payload, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
