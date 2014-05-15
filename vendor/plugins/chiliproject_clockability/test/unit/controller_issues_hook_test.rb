require File.expand_path('../../test_helper', __FILE__)

module Clockability

  class ControllerIssuesHookTest < ActiveSupport::TestCase

    def test_send_data_to_clockability_should_call_proxy(context={})

      api_token_value = 'apitoken'
      api_token = mock()
      api_token.expects(:value).returns(api_token_value)

      user = mock()
      user.expects(:api_token).returns(api_token)

      activity = mock()
      activity.expects(:id).returns(8)

      project = mock()
      project.expects(:identifier).returns('nicopaezdevproject')
      project.expects(:custom_value_for).returns(1)
      CustomField.expects(:find_by_name).with('Sync with Clockability')

      date = DateTime.parse('2012-09-19T11:23:06-03:00')

      time_entry = mock()
      time_entry.expects(:spent_on).returns(date)
      time_entry.expects(:comments).returns('Comments')
      time_entry.expects(:activity).returns(activity)
      time_entry.expects(:project).times(2).returns(project)
      time_entry.expects(:hours).times(3).returns(21)
      time_entry.expects(:issue_id).returns('22')
      time_entry.expects(:user).returns(user)
      time_entry.expects(:id).times(3).returns(1)
      time_entry.expects(:synced=).with(true)
      time_entry.expects(:save)

      context = {:time_entry => time_entry}

      expected_data = '{"ExternalActivityId":8,"ExternalIssueNumber":"22","ExternalProjectId":"nicopaezdevproject","ExternalTimeEntryId":1,"LogDate":"\/Date(1348064586000)\/","Notes":"Comments","WorkedHours":21,"WorkedMinutes":0}'
      proxy = mock()

      proxy.expects(:send_data).with(expected_data,api_token_value).returns("{\"Code\":\"100\",\"Message\":\"OK\"}")
      Clockability::ClockabilityProxy.expects(:new).returns(proxy)

      Clockability::ControllerIssuesHook.send_data_to_clockability(context)

     end

    def test_send_data_to_clockability_should_not_call_proxy_when_project_not_sync(context={})

      project = mock()
      project.stubs(:identifier).returns('zaraza')
      project.expects(:custom_value_for).returns(false)
      CustomField.expects(:find_by_name).with('Sync with Clockability')

      time_entry = mock()

      time_entry.expects(:project).returns(project)
      time_entry.expects(:hours).times(1).returns(1)
      time_entry.stubs(:id).returns(1)

      context = {:time_entry => time_entry}


      Clockability::ControllerIssuesHook.send_data_to_clockability(context)

    end

    def test_send_data_to_clockability_should_not_call_proxy_when_no_time_logged(context={})
      context = {:time_entry => nil}
      Clockability::ControllerIssuesHook.send_data_to_clockability(context)
    end

  end

end
