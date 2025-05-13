require 'rails_helper'

RSpec.describe WebhookProcessingJob, type: :job do
  describe '#perform' do
    it 'processes a webhook event successfully' do
      event = WebhookEvent.create(id: 1)
      service = instance_double(Pinpoint::ApplicationHiredHibobService)

      allow(Pinpoint::ApplicationHiredHibobService).to receive(:new).with(event).and_return(service)
      allow(service).to receive(:call)

      WebhookProcessingJob.new.perform(event.id)

      expect(Pinpoint::ApplicationHiredHibobService).to have_received(:new).with(event)
      expect(service).to have_received(:call)
    end

    it 'does nothing when event is not found' do
      non_existent_id = 999

      expect {
        WebhookProcessingJob.new.perform(non_existent_id)
      }.not_to raise_error
    end

    it 'updates event status and reraises error when exception occurs' do
      event = WebhookEvent.create(id: 1)
      service = instance_double(Pinpoint::ApplicationHiredHibobService)
      error = StandardError.new('Something went wrong')

      allow(Pinpoint::ApplicationHiredHibobService).to receive(:new).with(event).and_return(service)
      allow(service).to receive(:call).and_raise(error)

      expect {
        WebhookProcessingJob.new.perform(event.id)
      }.to raise_error(StandardError, 'Something went wrong')

      event.reload
      expect(event.status).to eq("failed")
      expect(event.error_message).to eq('Something went wrong')
    end
  end
end
