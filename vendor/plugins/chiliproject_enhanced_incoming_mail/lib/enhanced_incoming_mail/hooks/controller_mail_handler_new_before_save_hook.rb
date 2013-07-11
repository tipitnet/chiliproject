module EnhancedIncomingMail
  module Hooks
    class ControllerMailHandlerNewBeforeSaveHook < Redmine::Hook::ViewListener
      def controller_mail_handler_new_before_save(context={})

        if context[:params] && context[:params][:issue]
          # mask a problem with TMAIL and Microsoft Entourage generated mail.  TMAIL drops the content header declaration 'Content-Id'
          context[:params][:email] = context[:params][:email].gsub(/.*Content-ID:/i, 'Content-Id*:')

          begin
            normalized_mail = MailNormalizatorFactory.create_mail_normalized(context[:params][:email])
            
            # remove text plain part if HTML part available
            normalized_mail.remove_nonhtml_text!

            # normalize ChiliProject supported HTML tags
            normalized_mail.clean_format!

            # remove thread if it's a reply email
            normalized_mail.remove_thread!

            # replace IMG tags with image reference (e.g. !image.gif!)
            normalized_mail.embed_images!

            context[:params][:email] = normalized_mail.email
  
            Rails.logger.debug("Incoming email successfully processed. Output:\n\t#{context[:params][:email]}")            
          rescue Exception
            Rails.logger.error($!)
          end
        end
      end
    end
  end
end
