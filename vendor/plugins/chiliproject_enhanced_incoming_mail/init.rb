require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :chiliproject_enhanced_incoming_mail do

  require_dependency 'mail_handler_controller'
  unless MailHandlerController.included_modules.include? EnhancedIncomingMail::MailHandlerControllerPatch
    MailHandlerController.send(:include, EnhancedIncomingMail::MailHandlerControllerPatch)
  end

end

Redmine::Plugin.register :chiliproject_enhanced_incoming_mail do
  name 'Chiliproject Enhanced Incoming Mail plugin'
  author 'Diego Marcet'
  description 'Extend support of incoming emails that generate new Issue to include inline images and simple html tags (i.e. <b>, <i>, <del>)'
  version '0.0.1'
  author_url 'http://www.tipit.net/about'
end

require 'enhanced_incoming_mail/hooks/controller_mail_handler_new_before_save_hook'
require 'enhanced_incoming_mail/hooks/controller_mail_handler_new_after_error_hook'