require 'redmine'

Redmine::Plugin.register :chiliproject_mailgun_mail_handler do
  name 'chiliproject_mailgun_mail_handler plugin'
  author 'Nicolas Paez'
  description 'This plugin implements integration with Mailgun.'
  version '1.0.0'
  url 'http://www.tipit.net/about'
end

if Rails.env.production?
  EmailHandler.setup :api_key => ENV['MAILGUN_API_KEY']
else
  EmailHandler.setup :api_key => 'xx'
end
ProjectDetectionStrategy.global_inbox = ENV['GLOBAL_INBOX_PROJECT']