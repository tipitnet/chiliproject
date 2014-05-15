module Clockability

  class ClockabilityProxy

    def self.generate_json_message(time_entry)
      # Extract data from Chili model
      external_issue_number = time_entry.issue_id
      external_activity_id = time_entry.activity.id
      external_project_id = time_entry.project.identifier
      external_time_entry_id = time_entry.id
      log_date = (time_entry.spent_on.to_time.to_i) * 1000
      notes = time_entry.comments
      worked_hours = TimeConversor.extract_hours(time_entry.hours)
      worked_minutes = TimeConversor.extract_minutes(time_entry.hours)

      # Prepare the json message
      data = '{"ExternalActivityId":' + external_activity_id.to_s + ','
      data += '"ExternalIssueNumber":"' + external_issue_number.to_s + '",'
      data += '"ExternalProjectId":"' + external_project_id + '",'
      data += '"ExternalTimeEntryId":' + external_time_entry_id.to_s + ','
      data += '"LogDate":"\/Date(' + log_date.to_s + ')\/",'
      data += '"Notes":"' + notes + '",'
      data += '"WorkedHours":' +  worked_hours.to_s + ','
      data += '"WorkedMinutes":' + worked_minutes.to_s + '}'
      return data
    end

    def send_data(json_data, user_key)
      clock_endpoint = ENV['CLOCKABILITY_ENDPOINT']
=begin      
      if Rails.env.production?
        clock_endpoint = 'https://clockability.com/services/TimeEntriesService.svc/timeentry/add'
      else
        clock_endpoint = 'https://clockability.dev5.tipit.net/services/TimeEntriesService.svc/timeentry/add'
      end
=end
      resource = RestClient::Resource.new(clock_endpoint, :headers => { :'X-CLOCKABILITY-API-USER-KEY' => user_key })
      response = resource.post(json_data, :content_type => 'application/json')
      return response
    end

  end

end