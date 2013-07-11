require "mailer"

module EnhancedIncomingMail
  class EnhancedIncomingMailMailer < Mailer
    def problem_creating(email_subject, email_author, email)
      recipients email_author
      subject "Cannot Create Issue [#{email_subject}]"
      body = {
           :email_subject => email_subject
      }
      render_multipart('problem_mailer', body)
    end
  end
end
