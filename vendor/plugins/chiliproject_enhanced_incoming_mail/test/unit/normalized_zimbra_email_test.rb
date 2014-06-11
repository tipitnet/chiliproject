require File.expand_path('../../test_helper', __FILE__)

class NormalizedZimbraEmailTest < ActiveSupport::TestCase
	include Helper

	def test_remove_reply_thread_version_7_2_0
		raw_email = get_mail_sample :zimbra_7_2_0_reply
		email = Mail.new(raw_email.to_s)
		normalized_email = EnhancedIncomingMail::NormalizedZimbraEmail.new email

		normalized_email.remove_thread!

		replaced_email = normalized_email.email

		assert_match /Reply from Zimbra/, replaced_email
    assert_no_match /Status: New/, replaced_email

  end

  def test_remove_reply_thread_version_8_0_6
    raw_email = get_mail_sample :zimbra_8_0_6_reply
    email = Mail.new(raw_email.to_s)
    normalized_email = EnhancedIncomingMail::NormalizedZimbraEmail.new email

    normalized_email.remove_thread!

    replaced_email = normalized_email.email

    assert_match /I'm still seeing some instances where/, replaced_email
    assert_no_match /Assignee: JP Maxwell/, replaced_email
  end

  def test_replace_unsupported_html_tags
    raw_email = get_mail_sample :zimbra_7_2_0_reply
    email = Mail.new(raw_email.to_s)
    normalized_email = EnhancedIncomingMail::NormalizedZimbraEmail.new email

    normalized_email.clean_format!

    #addtionally to all the transformations performed in the base class, this case has to remove the head tag
    assert_no_match /<head>/, normalized_email.email
  end

end