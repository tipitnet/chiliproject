module TipitExtensions

  class BouncedDelivery
    attr_accessor :status_info, :original_message_id, :final_recipient, :issue_id

    def self.from_email(email)
      returning(bounce = self.new) do
        status_part = email.parts.detect do |part|
          part.content_type == "message/delivery-status"
        end
        statuses = status_part.body.split(/\n/)
        bounce.status_info =  statuses.inject({}) do |hash, line|
          key, value = line.split(/:/)
          hash[key] = value.strip rescue nil
          if key == 'Final-Recipient'
            no_matter, bounce.final_recipient = value.split(/;/)
            bounce.final_recipient.gsub!(" ",'')
            bounce.final_recipient.gsub!("\r",'')
          end
          hash
        end
        original_message_part = email.parts.detect do |part|
          part.content_type == "message/rfc822"
        end
        parsed_msg = TMail::Mail.parse(original_message_part.body)
        if m = parsed_msg.subject.match(ISSUE_REPLY_SUBJECT_RE)
          bounce.issue_id = m[1].to_i
        end
        bounce.original_message_id = parsed_msg.message_id
      end
    end

    ISSUE_REPLY_SUBJECT_RE = %r{\[[^\]]*#(\d+)\]}

    def status
      case status_info['Status']
        when /^5/
          'Failure'
        when /^4/
          'Temporary Failure'
        when /^2/
          'Success'
      end
    end
  end

end