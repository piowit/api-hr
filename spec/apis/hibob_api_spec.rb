require 'rails_helper'

RSpec.describe HibobApi do
  describe '.create_employee' do
    it 'creates an employee successfully', vcr: { cassette_name: 'hibob/create_employee_success' } do
      employee_data = {
        firstName: 'Piotr',
        surname: 'Witek',
        email: 'test_piotr_witek@pinpoint.dev',
        work: {
          site: 'New York (Demo)',
          startDate: '2025-06-01'
        }
      }

      response = HibobApi.create_employee(employee_data)

      expect(response).to be_success
      expect(response.parsed_response).to include('id')
      expect(response.parsed_response['firstName']).to eq('Piotr')
      expect(response.parsed_response['surname']).to eq('Witek')
      expect(response.parsed_response['email']).to eq('test_piotr_witek@pinpoint.dev')
    end

    it 'raises an error when employee data is invalid', vcr: { cassette_name: 'hibob/create_employee_invalid' } do
      invalid_employee_data = {
        firstName: 'Jane',
      }

      expect {
        HibobApi.create_employee(invalid_employee_data)
      }.to raise_error(StandardError, /Hibob API Request Failed/)
    end
  end

  describe '.upload_document_from_url' do
    it 'uploads a document successfully', vcr: { cassette_name: 'hibob/upload_document_success' } do
      employee_id = '3631726758354485431'
      file_url = 'https://pinpointhq.com/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBM0thK0E9PSIsImV4cCI6bnVsbCwicHVyIjoiYmxvYl9pZCJ9fQ==--f381b92262aa1a8f2f759c8da39ca4b874819f4d/tom_hacquoil.pdf'
      file_name = 'tom_hacquoil.pdf'

      response = HibobApi.upload_document_from_url(employee_id, file_url, file_name)

      expect(response).to be_success
      expect(response.parsed_response).to include('id')
      expect(response.parsed_response['name']).to eq(file_name)
    end

    it 'raises an error when employee does not exist', vcr: { cassette_name: 'hibob/upload_document_employee_not_found' } do
      employee_id = 'nonexistent'
      file_url = 'https://example.com/files/resume.pdf'
      file_name = 'Resume.pdf'

      expect {
        HibobApi.upload_document_from_url(employee_id, file_url, file_name)
      }.to raise_error(StandardError, /Hibob API Request Failed/)
    end
  end
end
