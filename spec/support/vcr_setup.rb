require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = false

  # Filter sensitive data
  c.filter_sensitive_data('<PINPOINT_API_KEY>') { Rails.application.credentials.dig(:pinpoint, :api_key) }
  c.filter_sensitive_data('<HIBOB_USER>') { Rails.application.credentials.dig(:hibob, :user) }
  c.filter_sensitive_data('<HIBOB_TOKEN>') { Rails.application.credentials.dig(:hibob, :token) }

  c.default_cassette_options = {
    record: :once,
    match_requests_on: [ :method, :uri, :body ],
    serialize_with: :json
  }
end
