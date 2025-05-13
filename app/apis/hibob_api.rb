# https://apidocs.hibob.com/docs/api-service-users

class HibobApi
  include HTTParty
  base_uri "https://api.hibob.com/v1"
  basic_auth Rails.application.credentials.dig(:hibob, :user), Rails.application.credentials.dig(:hibob, :token)
  headers "accept" => "application/json", "content-type" => "application/json"
  default_timeout 30

  def self.create_employee(employee_data)
    response = post("/people", body: employee_data.to_json)
    validate_response(response)
  end

  def self.upload_document_from_url(employee_id, file_url, file_name)
    body = {
      name: file_name,
      url: file_url,
      visibility: "employee"
    }
    response = post("/docs/people/#{employee_id}/shared", body: body.to_json)
    validate_response(response)
  end

  private_class_method def self.validate_response(response)
    return response if response.success?

    raise StandardError, "Hibob API Request Failed! Status: #{response.code}, Body: #{response.body}"
  end
end
