module Pinpoint
  class ApplicationHiredHibobService
    def initialize(event)
      @event = event
    end

    def call
      payload = @event.payload
      application_id = extract_application_id(payload)
      return unless application_id

      begin
        application_data = fetch_pinpoint_application_data(application_id)
        hibob_employee_id = create_hibob_employee(application_id, application_data)
        upload_cv_to_hibob_if_present(application_id, hibob_employee_id, application_data)
        add_pinpoint_comment(application_id, hibob_employee_id)
      rescue StandardError => e
        @event.update(status: "failed", error_message: e.message)
        raise e
      end

      @event.update(status: "processed", processed_at: Time.current)
    end

    private

    def extract_application_id(payload)
      application_id = payload.dig("data", "application", "id")
      if application_id.nil?
        @event.update(status: "failed", error_message: "No application ID found in payload")
        raise "No application ID found in payload"
      end

      application_id
    end

    def fetch_pinpoint_application_data(application_id)
      pinpoint_response = PinpointApi.fetch_application(application_id)
      pinpoint_response = pinpoint_response.parsed_response&.dig("data", "attributes")
      if pinpoint_response.nil?
        @event.update(status: "failed", error_message: "Application data is missing, cannot create HiBob employee for application ID #{application_id}")
        raise "Application data is missing, cannot create HiBob employee for application ID #{application_id}"
      end

      pinpoint_response
    end

    def create_hibob_employee(application_id, application_data)
      start_date = Date.today.next_month.beginning_of_month.strftime("%Y-%m-%d")
      hibob_employee_payload = {
        firstName: application_data["first_name"],
        surname: application_data["last_name"],
        email: application_data["email"],
        work: {
          site: "New York (Demo)",
          startDate: start_date
        }
      }

      hibob_create_response = HibobApi.create_employee(hibob_employee_payload)
      hibob_parsed_response = hibob_create_response.parsed_response
      hibob_employee_id = hibob_parsed_response.is_a?(Hash) ? hibob_parsed_response["id"] : nil

      if hibob_employee_id.nil?
        @event.update(status: "failed", error_message: "Failed to create employee in HiBob or missing ID for application ID #{application_id}. Status: #{hibob_create_response.code}, Body: #{hibob_create_response.body}")
        raise "HiBob employee creation failed or ID missing for application ID #{application_id}"
      end
      hibob_employee_id
    end

    def upload_cv_to_hibob_if_present(application_id, hibob_employee_id, application_data)
      pdf_cv_attachment = application_data["attachments"]&.find { |att| att["context"] == "pdf_cv" }
      return if pdf_cv_attachment.nil?

      HibobApi.upload_document_from_url(
        hibob_employee_id,
        pdf_cv_attachment["url"],
        pdf_cv_attachment["filename"]
      )
    end

    def add_pinpoint_comment(application_id, hibob_employee_id)
      comment_body = "Record created with ID: #{hibob_employee_id}"
      PinpointApi.create_application_comment(application_id, comment_body)
    end
  end
end
