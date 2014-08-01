require 'redmine'

Dispatcher.to_prepare :chiliproject_mailgun_mail_handler do

  require_dependency 'attachment'

  unless Attachment.included_modules.include? AttachmentPatch
    Attachment.send(:include, AttachmentPatch)
  end

=begin
  unless Mail::Part.module.include? MailPartPatch
    Mail::Part.send(:include, MailPartPatch)
  end
=end
end

Redmine::Plugin.register :chiliproject_mailgun_mail_handler do
  name 'chiliproject_mailgun_mail_handler plugin'
  author 'Nicolas Paez'
  description 'This plugin implements integration with Mailgun.'
  version '1.0.0'
  url 'http://www.tipit.net/about'
end

require 'mail_part_patch'

if Rails.env.production?
  EmailHandler.setup :api_key => ENV['MAILGUN_API_KEY']
else
  EmailHandler.setup :api_key => 'xx'
end
ProjectDetectionStrategy.global_inbox = ENV['GLOBAL_INBOX_PROJECT']