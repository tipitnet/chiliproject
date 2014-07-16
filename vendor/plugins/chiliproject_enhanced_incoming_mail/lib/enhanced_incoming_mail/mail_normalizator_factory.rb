module EnhancedIncomingMail

  class RawEmailError < EnhancedIncomingMailError
  end

  class MailNormalizatorFactory

    @@mail_types = {}


    def self.register_mail_type(mail_type)
      @@mail_types[mail_type.identifier] = mail_type
    end

    def self.initialize_mail_types
      self.register_mail_type(NormalizedGenericEmail)
      self.register_mail_type(NormalizedGmailEmail)
      self.register_mail_type(NormalizedMacMailEmail)
      self.register_mail_type(NormalizedOutlookEmail)
      self.register_mail_type(NormalizedOutlookmacEmail)
      self.register_mail_type(NormalizedPostboxEmail)
      self.register_mail_type(NormalizedThunderbirdEmail)
      self.register_mail_type(NormalizedZimbraEmail)
    end

    initialize_mail_types

    def self.create_mail_normalized(raw_email)
      if raw_email.nil? || raw_email.blank?
        raise RawEmailError, 'raw_email cannot be blank'
      end
      if raw_email.include?('charset=ISO-8859-1')
        i = Iconv.new('UTF-8','LATIN1')
        raw_email = i.iconv(raw_email)
        raw_email.gsub!('charset=ISO-8859-1','charset=utf-8')
      end
      email = Mail.new(raw_email.to_s)
      mail_type = @@mail_types[get_email_client_type(email)]
      mail_type.new(email)
    end

    private
    # determine mail client type
    def self.get_email_client_type(email)
      if(email.class != Mail::Message)
        email = Mail.new(email.to_s)
      end
      email_client = :other
      if email.header[:x_mailer]
        if email.header[:x_mailer].value =~ /apple mail/i                     # Mac Mail client generated
          email_client = :mac_mail
        elsif email.header[:x_mailer].value =~ /microsoft.+Outlook/i          # Microsoft Outlook client generated
          email_client = :ms_outlook
        elsif email.header[:x_mailer].value =~ /zimbra/i          # Zimbra client generated
          email_client = :zimbra
        end
      elsif email.header.to_s.index("Apple-Mail")
        email_client = :mac_mail
      elsif email.header[:message_id] && email.header[:message_id].value =~ /@mail\.gmail\.com/i
        email_client = :gmail
      elsif email.header[:user_agent] && email.header[:user_agent].value =~ /postbox/i
        email_client = :postbox
      elsif email.header[:user_agent] && email.header[:user_agent].value =~ /microsoft.+Outlook/i          # Microsoft Outlook client generated
        email_client = :ms_outlookmac
      elsif email.header[:user_agent] && email.header[:user_agent].value =~ /Thunderbird/i
        email_client = :thunderbird
      end

      if (email_client == :other && email.to_s =~ /urn:schemas-microsoft-com:office/ )
        email_client = :ms_outlook
      end

      email_client
    end
  end

end