require 'rails_helper'

RSpec.describe PinpointApi do
  describe '.fetch_application' do
    it 'fetches an application successfully', vcr: { cassette_name: 'pinpoint/fetch_application_success' } do
      application_id = '8863860'

      response = PinpointApi.fetch_application(application_id)

      expect(response).to be_success
      expect(response.parsed_response).to include('data')
      expect(response.parsed_response['data']['id']).to eq(application_id)
      expect(response.parsed_response['data']['type']).to eq('applications')
    end

    it 'raises an error when the application does not exist', vcr: { cassette_name: 'pinpoint/fetch_application_not_found' } do
      application_id = 'nonexistent-id'

      expect {
        PinpointApi.fetch_application(application_id)
      }.to raise_error(StandardError, /Pinpoint API Request Failed/)
    end
  end

  describe '.create_application_comment' do
    it 'creates a comment successfully', vcr: { cassette_name: 'pinpoint/create_application_comment_success' } do
      application_id = '8863860'
      comment = 'This is a test comment'

      response = PinpointApi.create_application_comment(application_id, comment)

      expect(response).to be_success
      expect(response.parsed_response).to include('data')
      expect(response.parsed_response['data']['type']).to eq('comments')
      expect(response.parsed_response['data']['attributes']['body_text']).to eq(comment)
    end

    it 'raises an error when the application does not exist', vcr: { cassette_name: 'pinpoint/create_application_comment_not_found' } do
      application_id = 'nonexistent-id'
      comment = 'This is a test comment'

      expect {
        PinpointApi.create_application_comment(application_id, comment)
      }.to raise_error(StandardError, /Pinpoint API Request Failed/)
    end
  end
end
