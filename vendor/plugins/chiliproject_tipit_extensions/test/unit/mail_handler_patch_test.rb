require File.expand_path('../../test_helper', __FILE__)

module TipitExtensions

  module MailHandlerPatch

    class MailHandlerPatchTest < ActiveSupport::TestCase
      include TipitExtensionHelper

      def test_valid_recipients_should_reject_mails_with_multiple_to
        MailHandler.send(:include, TipitExtensions::MailHandlerPatch)
        Mailer.expects(:deliver_issue_reject_to).with(['someuser@someplace.com'],'Mail with multiple TO')
        email = get_mail_sample :mail_with_multiple_to

        MailHandler.receive(email)
      end

      def test_valid_recipients_should_reject_mails_with_cc
        MailHandler.send(:include, TipitExtensions::MailHandlerPatch)
        Mailer.expects(:deliver_issue_reject_to).with(['someuser@someplace.com'],'Mail with CC')
        email = get_mail_sample :mail_with_cc

        MailHandler.receive(email)
      end

      def test_remove_issue_watcher_should_look_for_user_and_remove_it
        user_email = 'nobody@tipit.net'
        issue = mock()
        user = mock()
        issue.expects(:remove_watcher).with(user)
        User.expects(:find_by_mail).with(user_email).returns(user)
        Issue.expects(:find_by_id).returns(issue)

        email = get_mail_sample :bounced_issue
        MailHandler.receive(email)
      end
    end
  end
end