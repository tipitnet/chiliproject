module EnhancedIncomingMail
  module Hooks
    class ControllerMailHandlerNewAfterErrorHook < Redmine::Hook::ViewListener
      def controller_mail_handler_new_after_error(context={})
        email = context[:params][:email]
        original_subject = email.match(/Subject: (.+?)\n/i)
        email_author = email.match(/From: (.+?)\n/i)
        email_subject = original_subject[1]
        EnhancedIncomingMailMailer.deliver_problem_creating(email_subject, email_author, email)
      end
    end
  end
end
