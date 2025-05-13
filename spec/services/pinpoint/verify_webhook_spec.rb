require 'rails_helper'

RSpec.describe Pinpoint::VerifyWebhook, type: :service do
  describe '#call' do
    it 'always returns true in development environment' do
      allow(Rails.env).to receive(:development?).and_return(true)

      request = instance_double('ActionDispatch::Request')
      result = Pinpoint::VerifyWebhook.new(request).call

      expect(result).to be true
    end

    it 'returns false when HMAC header is missing' do
      allow(Rails.env).to receive(:development?).and_return(false)

      request = instance_double('ActionDispatch::Request', headers: {})
      result = Pinpoint::VerifyWebhook.new(request).call

      expect(result).to be false
    end

    it 'returns false when computed HMAC does not match the header' do
      allow(Rails.env).to receive(:development?).and_return(false)

      request = instance_double(
        'ActionDispatch::Request',
        headers: { 'PINPOINT-HMAC-SHA256' => 'invalid_hmac' },
        body: StringIO.new('request body')
      )

      verifier = Pinpoint::VerifyWebhook.new(request)
      allow(verifier).to receive(:computed_hmac).and_return('computed_hmac')

      result = verifier.call

      expect(result).to be false
    end

    it 'returns true when computed HMAC matches the header' do
      allow(Rails.env).to receive(:development?).and_return(false)

      request = instance_double(
        'ActionDispatch::Request',
        headers: { 'PINPOINT-HMAC-SHA256' => 'valid_hmac' },
        body: StringIO.new('request body')
      )

      verifier = Pinpoint::VerifyWebhook.new(request)
      allow(verifier).to receive(:computed_hmac).and_return('valid_hmac')

      result = verifier.call

      expect(result).to be true
    end
  end
end
