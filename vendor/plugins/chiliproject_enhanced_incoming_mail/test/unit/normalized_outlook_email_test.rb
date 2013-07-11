require File.expand_path('../../test_helper', __FILE__)

class NormalizedOutlookEmailTest < Test::Unit::TestCase
	include Helper

	def test_remove_plain_text
		raw_email = get_mail_sample :outlook_rich_text
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedOutlookEmail.new email
		normalized_email.remove_nonhtml_text!

		replaced_email = normalized_email.email
		assert_match /text\/html/i, replaced_email
		assert_no_match /text\/plain/i, replaced_email
	end

	def test_remove_plain_text_when_image_embedded
		raw_email = get_mail_sample :outlook_embedded_image
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedOutlookEmail.new email			
		normalized_email.remove_nonhtml_text!

		replaced_email = normalized_email.email
		assert_match /text\/html/i, replaced_email
		assert_no_match /text\/plain/i, replaced_email
	end

	def test_embed_image
		raw_email = get_mail_sample :outlook_embedded_image
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedOutlookEmail.new email
		normalized_email.embed_images!

		replaced_email = normalized_email.email
		assert_match /\!image001.jpg\!/i, replaced_email
		assert_no_match /src="cid:image001.jpg@01CD6343.35F8AA20"/i, replaced_email
		assert_no_match /Content-Disposition: inline/i, replaced_email
		# Content-Disposition header is not mandatory (if not present 'attachment' disposition is used by default)
		if replaced_email.match(/Content-Disposition/i)
			assert_match /Content-Disposition: attachment/i, replaced_email
		end
	end

	def test_remove_reply_thread
		raw_email = get_mail_sample :outlook_reply
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedOutlookEmail.new email
		normalized_email.remove_thread!

		replaced_html_body = get_decoded_html_body(normalized_email.email)
		assert_match />This is the REPLY message\.</m, replaced_html_body
		assert_no_match /This is the ORIGINAL email, to be removed\./, replaced_html_body
		assert_no_match /You have received this notification because you have either subscribed/, replaced_html_body
  end

  def test_remove_reply_thread_from_outlook_for_mac
    raw_email = get_mail_sample :outlook_mac_reply
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedOutlookmacEmail.new email
    normalized_email.remove_thread!

    replaced_html_body = get_decoded_html_body(normalized_email.email)
    assert replaced_html_body.include?('better')
    assert_no_match /THIS SHOULD BE REMOVED\./, replaced_html_body
  end

end