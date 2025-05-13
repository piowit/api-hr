# https://developers.pinpointhq.com/docs/introduction

class PinpointApi
  include HTTParty
  base_uri "https://developers-test.pinpointhq.com/api/v1"
  headers "x-api-key" => Rails.application.credentials.dig(:pinpoint, :api_key),
          "accept" => "application/json",
          "content-type" => "application/json"
  default_timeout 30

  def self.fetch_application(application_id)
    query = { "extra_fields[applications]" => "attachments" }
    response = get("/applications/#{application_id}", query: query)
    validate_response(response)
  end

  def self.create_application_comment(application_id, comment)
    body = {
      data: {
        type: "comments",
        attributes: {
          body_text: comment
        },
        relationships: {
          commentable: {
            data: {
              type: "applications",
              id: application_id.to_s
            }
          }
        }
      }
    }
    response = post("/comments", body: body.to_json)
    validate_response(response)
  end

  private_class_method def self.validate_response(response)
    return response if response.success?

    raise StandardError, "Pinpoint API Request Failed! Status: #{response.code}, Body: #{response.body}"
  end
end
