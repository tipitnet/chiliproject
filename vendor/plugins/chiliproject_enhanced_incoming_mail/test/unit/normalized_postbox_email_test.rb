require File.expand_path('../../test_helper', __FILE__)

class NormalizedPostboxEmailTest < ActiveSupport::TestCase
	include Helper

	def test_replace_unsupported_html_tags
		raw_email = get_mail_sample :postbox_rich_text
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email
		normalized_email.clean_format!

		replaced_html_body = get_decoded_html_body(normalized_email.email)
		assert_match /\#.+?First item/, replaced_html_body
		assert_match /\#.+?Second item/, replaced_html_body
		assert_match /\*.+?First item/, replaced_html_body
		assert_match /\*.+?Second item/, replaced_html_body
		assert_no_match /\<li\>/, replaced_html_body
		assert_match /h1\. This is a Heading 1/, replaced_html_body
		assert_match /h2\. This is a Heading 2/, replaced_html_body
		assert_match /h3\. This is a Heading 3/, replaced_html_body
		assert_match /_This is italic_/, replaced_html_body
		assert_match /\*This is bolded\*/, replaced_html_body
		assert_match /\+And finally, this is underlined\+/, replaced_html_body
	end

	def test_embed_image
		raw_email = get_mail_sample :postbox_embedded_image
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email
		normalized_email.embed_images!

		replaced_email = normalized_email.email
		assert_match /\!part1.06000102.07030003.jpeg\!/i, replaced_email
		assert_no_match /Content-Disposition: inline/i, replaced_email
 		assert_match /Content-Disposition: attachment/i, replaced_email
  end


  def test_embed_image_version_2
    raw_email = get_mail_sample :postbox_embedded_image_2
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email
    normalized_email.embed_images!

    replaced_email = normalized_email.email
    assert_match /\!image.png\!/i, replaced_email
    assert_no_match /Content-Disposition: inline/i, replaced_email
    assert_match /Content-Disposition: attachment/i, replaced_email
  end


	def test_remove_reply_thread
		raw_email = get_mail_sample :postbox_reply
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email				
		normalized_email.remove_thread!

		replaced_email = normalized_email.email
		assert_match /This is the REPLY text and must be included in the comment./m, replaced_email
		assert_no_match /<p>This is the ORIGINAL email, to <br>be removed from the reply<\/p>/, replaced_email
	end

	def test_remove_unreferenced_inline_image
		raw_email = get_mail_sample :postbox_reply
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email				
		normalized_email.remove_thread!

		replaced_email = normalized_email.email
		assert_no_match /Content-ID: <part1\.06070703.03030604@someplace\.com>/, replaced_email
	end

	def test_dont_remove_referenced_inline_image
		raw_email = get_mail_sample :postbox_reply_with_image
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email		
		normalized_email.remove_thread!

		replaced_email = normalized_email.email
		assert_match /Content-ID: <part1\.04090307.00030702@someplace\.com>/, replaced_email
		assert_no_match /Content-ID: <part2\.01090403.07030800@someplace\.com>/, replaced_email
	end

  def test_dont_additional_spaces
    raw_email = get_mail_sample :postbox_spacing
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedPostboxEmail.new email
    normalized_email.clean_format!

    replaced_html_body = get_decoded_html_body(normalized_email.email)
    assert_match /This is a test to test some testing with. Why /, replaced_html_body

  end
end