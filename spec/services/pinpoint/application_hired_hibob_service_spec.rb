require 'rails_helper'
require 'vcr'
require 'ostruct'

RSpec.describe Pinpoint::ApplicationHiredHibobService, type: :service do
  describe '#call' do
    it 'processes application data and creates employee in HiBob successfully' do
      VCR.use_cassette('pinpoint/application_hired_success') do
        payload = {
          "event" => "application_hired",
          "triggeredAt" => 1614687278,
          "data" => {
            "application" => {
              "id" => 8863861
            },
            "job" => {
              "id" => 1
            }
          }
        }

        event = WebhookEvent.create!(
          source: "pinpoint",
          headers: {},
          payload: payload,
          status: "pending"
        )

        service = Pinpoint::ApplicationHiredHibobService.new(event)
        service.call
        expect(event.reload.status).to eq("processed")
      end
    end

    it 'handles missing application ID' do
      payload = {wrong: "payload"}

      event = WebhookEvent.create!(
        source: "pinpoint",
        headers: {},
        payload: payload,
        status: "pending"
      )

      service = Pinpoint::ApplicationHiredHibobService.new(event)

      expect {
        service.call
      }.to raise_error(RuntimeError, "No application ID found in payload")
    end

    it 'handles missing application data' do
      VCR.use_cassette('pinpoint/application_hired_missing_data') do
        payload = {
          "event" => "application_hired",
          "triggeredAt" => 1614687278,
          "data" => {
            "application" => {
              "id" => 9999999999
            },
            "job" => {
              "id" => 1
            }
          }
        }

        event = WebhookEvent.create!(
          source: "pinpoint",
          headers: {},
          payload: payload,
          status: "pending"
        )

        service = Pinpoint::ApplicationHiredHibobService.new(event)

        expect {
          service.call
        }.to raise_error(StandardError)
        expect(event.reload.status).to eq("failed")
      end
    end

    it 'handles failed HiBob employee creation' do
      VCR.use_cassette('pinpoint/application_hired_hibob_failure') do
        payload = {
          "event" => "application_hired",
          "triggeredAt" => 1614687278,
          "data" => {
            "application" => {
              "id" => 9999999999
            },
            "job" => {
              "id" => 1
            }
          }
        }

        event = WebhookEvent.create!(
          source: "pinpoint",
          headers: {},
          payload: payload,
          status: "pending"
        )

        service = Pinpoint::ApplicationHiredHibobService.new(event)

        expect {
          service.call
        }.to raise_error(StandardError)
        expect(event.reload.status).to eq("failed")
      end
    end
  end
end
