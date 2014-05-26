require File.expand_path('../../test_helper', __FILE__)

class NormalizedGmailEmailTest < ActiveSupport::TestCase
	include Helper

	def test_replace_big_font_with_headings
		raw_email = get_mail_sample :gmail_replace_headings
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedGmailEmail.new email
		normalized_email.clean_format!

		replaced_html_body = get_decoded_html_body(normalized_email.email)
		assert_match /h1\. This is HUGE text and should be transformed to h1/i, replaced_html_body
		assert_match /h2\. This is LARGE text and should be transformed to h2/i, replaced_html_body
		assert_no_match /\<font .+?\>This is NORMAL text and should be kept that way\<\/font.*/i, replaced_html_body
		assert_no_match /\<font .+?\>This is SMALL text and should be transformed to regular text\<\/font.*/i, replaced_html_body
	end	

	def test_remove_reply_thread
		raw_email = get_mail_sample :gmail_reply
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedGmailEmail.new email
		normalized_email.remove_thread!

		replaced_html_body = get_decoded_html_body(normalized_email.email)
		assert_match />This is the REPLY text and must be included in the comment\.</m, replaced_html_body
		assert_no_match /This is the ORIGINAL email, to be removed from the reply\./, replaced_html_body
		assert_no_match /You have received this notification because you have either subscribed/, replaced_html_body
  end

  def test_properly_process_fw_mail_content
    raw_email = get_mail_sample :gmail_fw
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedGmailEmail.new email
    normalized_email.remove_thread!

    replaced_html_body = get_decoded_html_body(normalized_email.email)
    assert_match /This is the content/, replaced_html_body
    assert_match /Some content FW/, replaced_html_body
  end

end