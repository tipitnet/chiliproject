require File.expand_path('../../test_helper', __FILE__)

module TipitExtensions

  module IssuePatch

    class IssuePatchTest <  ActiveSupport::TestCase

      def test_set_start_date_should_not_set_when_is_new_issue
        Issue.send(:include, TipitExtensions::IssuePatch)

        new_status_mock = mock()
        new_status_mock.stubs(:id).returns(1)
        IssueStatus.expects(:find_by_name).returns(new_status_mock)

        issue = Issue.new
        issue.subject = "Subject"

        issue.set_start_date

        assert_equal(nil, issue.start_date)
      end

      def test_set_start_date_should_set_when_issue_is_changed_from_new
        Issue.send(:include, TipitExtensions::IssuePatch)

        new_status_mock = mock()
        new_status_mock.stubs(:id).returns(0)
        IssueStatus.expects(:find_by_name).returns(new_status_mock)

        not_new_status_mock = IssueStatus.new
        not_new_status_mock.stubs(:id).returns(2)


        issue = Issue.new
        issue.subject = "Subject"
        issue.status_id = new_status_mock.id
        issue.save
        issue.status_id = not_new_status_mock.id

        issue.set_start_date

        assert_equal(Date.today, issue.start_date)
      end

      def test_add_asignee_as_watcher_should_add_assignee_as_watcher_when_it_changes
        Issue.send(:include, TipitExtensions::IssuePatch)

        user = User.new
        user.stubs(:id).returns(5)

        issue = Issue.new
        issue.subject = "Subject"
        issue.expects(:watched_by?).returns(false)
        issue.assigned_to = user
        issue.assigned_to_id = user.id
        issue.add_asignee_as_watcher

        assert_equal(user.id, issue.watchers[0].user.id)
      end


      def test_add_asignee_as_watcher_should_not_add_assignee_as_watcher_when_it_not_changes
        Issue.send(:include, TipitExtensions::IssuePatch)

        user = User.new
        user.stubs(:id).returns(5)

        issue = Issue.new
        issue.subject = "Subject"
        issue.add_asignee_as_watcher
        assert_equal(0, issue.watchers.size)
      end

      def test_add_asignee_as_watcher_should_add_assignee_as_watcher_when_is_already_watcher
        Issue.send(:include, TipitExtensions::IssuePatch)

        user = User.new
        user.stubs(:id).returns(5)

        issue = Issue.new
        issue.subject = "Subject"
        issue.expects(:watched_by?).returns(true)
        issue.expects(:set_watcher).never
        issue.assigned_to = user
        issue.assigned_to_id = user.id
        issue.add_asignee_as_watcher
      end

    end

  end

end

