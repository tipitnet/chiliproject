module EnhancedIncomingMail

  class MailRecord < ActiveRecord::Base
    include Redmine::SafeAttributes
    safe_attributes 'email_address', 'email_client_app'

    def self.create_from(normalizedEmail)
      mail_record = MailRecord.new
      mail_record.email_address = normalizedEmail.from
      mail_record.email_client_app = normalizedEmail.client_app
      mail_record.save
    end

  end

end
