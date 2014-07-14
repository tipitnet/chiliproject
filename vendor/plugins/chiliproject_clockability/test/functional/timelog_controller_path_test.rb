require File.expand_path('../../../../../../test/test_helper', __FILE__)
require 'timelog_controller'

# Re-raise errors caught by the controller.
class TimelogController; def rescue_action(e) raise e end; end

class TimelogControllerPatchTest < ActionController::TestCase
  fixtures :projects, :enabled_modules, :roles, :members, :member_roles, :issues, :time_entries, :users, :trackers, :enumerations, :issue_statuses, :custom_fields, :custom_values

  def setup
    @controller = TimelogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_post_create_should_not_call_proxy_when_sync_is_nil
    # TODO: should POST to issues’ time log instead of project. change form
    # and routing

    Clockability::ClockabilityProxy.expects(:new).times(0)


    @request.session[:user_id] = 3
    post :create, :project_id => 1,
                :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2008-03-14',
                                :issue_id => '1',           
                                :hours => '7.3'}
    assert_redirected_to :action => 'index', :project_id => 'ecookbook'

    i = Issue.find(1)
    t = TimeEntry.find_by_comments('Some work on TimelogControllerTest')
    assert_not_nil t
    assert_equal 11, t.activity_id
    assert_equal 7.3, t.hours
    assert_equal 3, t.user_id
    assert_equal i, t.issue
    assert_equal i.project, t.project
  end


  def test_post_create_should_not_call_proxy_when_sync_is_false
    Project.any_instance.expects(:sync_with_clock).returns(false)
    Clockability::ClockabilityProxy.expects(:new).times(0)

    @request.session[:user_id] = 3
    post :create, :project_id => 1,
                :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2008-03-14',
                                :issue_id => '1',           
                                :hours => '7.3'}
    assert_redirected_to :action => 'index', :project_id => 'ecookbook'

    i = Issue.find(1)
    t = TimeEntry.find_by_comments('Some work on TimelogControllerTest')
    assert_not_nil t
    assert_equal 11, t.activity_id
    assert_equal 7.3, t.hours
    assert_equal 3, t.user_id
    assert_equal i, t.issue
    assert_equal i.project, t.project
  end

  def test_post_create_should_call_proxy_when_sync_is_true
    # TODO: should POST to issues’ time log instead of project. change form
    # and routing

    Project.any_instance.expects(:sync_with_clock).returns(true)

    api_token_mock = mock()
    api_token_mock.expects(:value).returns('xxx')
    User.any_instance.expects(:api_token).returns(api_token_mock)

    proxy = mock()
    proxy.expects(:send_data).returns("{\"Code\":\"100\",\"Message\":\"OK\"}")
    Clockability::ClockabilityProxy.expects(:new).returns(proxy)

    @request.session[:user_id] = 3
    post :create, :project_id => 1,
                :time_entry => {:comments => 'Some work on TimelogControllerTest',
                                # Not the default activity
                                :activity_id => '11',
                                :spent_on => '2008-03-14',
                                :issue_id => '1',           
                                :hours => '7.3'}
    assert_redirected_to :action => 'index', :project_id => 'ecookbook'

    i = Issue.find(1)
    t = TimeEntry.find_by_comments('Some work on TimelogControllerTest')
    assert_not_nil t
    assert_equal 11, t.activity_id
    assert_equal 7.3, t.hours
    assert_equal 3, t.user_id
    assert_equal i, t.issue
    assert_equal i.project, t.project
  end

end
