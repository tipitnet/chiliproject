module EnhancedIncomingMail
  module Hooks
    class ControllerMailHandlerNewBeforeSaveHook < Redmine::Hook::ViewListener

      def received_mail_logger
        @@tipit_logger ||= create_logger
      end

      def create_logger
        tipit_logger = Logger.new("#{Rails.root}/log/received_emails.log", 'daily')
        tipit_logger.level = Logger::DEBUG
        tipit_logger.formatter = proc do |severity, datetime, progname, msg|
          "#{severity} [#{datetime}] - #{progname}: #{msg}\n"
        end
        tipit_logger
      end

      def controller_mail_handler_new_before_save(context={})

        if context[:params] && context[:params][:issue]
          # mask a problem with TMAIL and Microsoft Entourage generated mail.  TMAIL drops the content header declaration 'Content-Id'
          context[:params][:email] = context[:params][:email].gsub(/.*Content-ID:/i, 'Content-Id*:')
          context[:params][:email] = context[:params][:email].gsub(/[^#{%Q{\x00-\x7f}}]/,'')

          begin
            received_mail_logger.info('Incoming email, starting normalization process')

            normalized_mail = MailNormalizatorFactory.create_mail_normalized(context[:params][:email])
            
            # remove text plain part if HTML part available
            received_mail_logger.debug('Normalization process: 1. remove_non_html.')
            normalized_mail.remove_nonhtml_text!

            # remove thread if it's a reply email
            received_mail_logger.debug('Normalization process: 3. remove thread.')
            normalized_mail.remove_thread!

            # normalize ChiliProject supported HTML tags
            received_mail_logger.debug('Normalization process: 2. clean html tags.')
            normalized_mail.clean_format!

            # replace IMG tags with image reference (e.g. !image.gif!)
            received_mail_logger.debug('Normalization process: 4. handle images.')
            normalized_mail.embed_images!

            context[:params][:email] = normalized_mail.email

            File.open('email_result.txt', 'w') {|f| f.write(normalized_mail.email) }

            received_mail_logger.info("Incoming email successfully normalized. Result: #{normalized_mail.email}")

          rescue Exception
            received_mail_logger.error($!.message)
            received_mail_logger.error($!.backtrace.join("\n"))
          end
        end
      end
    end
  end
end