require File.expand_path('../../test_helper', __FILE__)
#require 'test/unit'

class ClockabilityProxyTest < ActiveSupport::TestCase

  def test_generate_json_message_return_json
    time_entry = mock()
    time_entry.stubs(:issue_id).returns(123)

    activity = mock()
    activity.stubs(:id).returns(1)
    time_entry.stubs(:activity).returns(activity)

    project = mock()
    project.stubs(:identifier).returns("chili")
    time_entry.stubs(:project).returns(project)

    time_entry.stubs(:id).returns(1)
    time_entry.stubs(:spent_on).returns(DateTime.now)
    time_entry.stubs(:comments).returns('my name is "nico"')
    time_entry.stubs(:hours).returns(2)

    result = Clockability::ClockabilityProxy.generate_json_message(time_entry)
    parsed_object = JSON.parse result
    assert_equal("my name is nico", parsed_object['Notes'])
  end

end