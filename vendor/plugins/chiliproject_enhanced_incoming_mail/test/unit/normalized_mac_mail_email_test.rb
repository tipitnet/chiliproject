require File.expand_path('../../test_helper', __FILE__)

class NormalizedMacMailEmailTest < ActiveSupport::TestCase
	include Helper

	def test_replace_bold_tags
		raw_email = get_mail_sample :macmail_replace_bold_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match "This is *bold* text", normalized_email.email
	end

	def test_replace_italic_tags
		raw_email = get_mail_sample :macmail_replace_italic_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match "This is _italic_ text", normalized_email.email
	end

	def test_replace_underline_tags
		raw_email = get_mail_sample :macmail_replace_underline_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match "This is +underlined+ text", normalized_email.email
	end

	def test_replace_quote_tags
		raw_email = get_mail_sample :macmail_replace_quote_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match "This is ??quoted?? text", normalized_email.email
	end
=begin
	def test_replace_unordered_list_tags
		email = "This is a <ul><li>First Item</li><li>Second Item</li></ul> text"

		EnhancedIncomingMail::NormalizeEmail.clean_format email

		assert_equal "This is a * First Item\n* Second Item text", email
	end
=end
	def test_replace_paragraph_tags
		raw_email = get_mail_sample :macmail_replace_paragraph_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match /This is a paragraph\r?\nAnd this is another paragraph\r?\n/, normalized_email.email
	end

	def test_replace_heading1_tags
		raw_email = get_mail_sample :macmail_replace_heading1_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match /This is a \r?\n\r?\nh1. Heading 1\r?\n\r?\ntext/, normalized_email.email
	end

	def test_replace_heading2_tags
		raw_email = get_mail_sample :macmail_replace_heading2_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match /This is a \r?\n\r?\nh2. Heading 2\r?\n\r?\ntext/, normalized_email.email
	end

	def test_replace_heading3_tags
		raw_email = get_mail_sample :macmail_replace_heading3_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!

		assert_match /This is a \r?\n\r?\nh3. Heading 3\r?\n\r?\ntext/, normalized_email.email
	end

	def test_replace_links
		raw_email = get_mail_sample :macmail_replace_link_tags
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.clean_format!		

		replaced_email = normalized_email.email
		assert_match /This is a link to "http:\/\/www.link1.com":http:\/\/www.link1.com/, replaced_email
 		assert_match /This is a link to "link2":http:\/\/www.link2.com/, replaced_email
	end

	# def test_dont_update_email_if_not_reply
	# 	raw_email = get_mail_sample :macmail_simple_email

	# 	replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_thread email

	# 	assert_equal get_mail_sample(:macmail_simple_email), replaced_email
	# end

	def test_remove_reply_thread
		raw_email = get_mail_sample :macmail_reply
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.remove_thread!

		replaced_email = normalized_email.email
		assert_match /(?!>)New comment added from Mac Mail(?!<)/m, replaced_email
		assert_match />New comment added from Mac Mail</m, replaced_email
		assert_no_match /REMOVED/, replaced_email
	end

  def test_remove_reply_thread_2
    raw_email = get_mail_sample :macmail_reply_2
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
    normalized_email.remove_thread!

    replaced_email = normalized_email.email
    assert_match /What about this one.  How is it going/m, replaced_email
    assert_no_match /> Status: New/, replaced_email
  end

  def test_remove_reply_thread_3
    raw_email = get_mail_sample :macmail_reply_3
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
    normalized_email.remove_thread!

    replaced_email = normalized_email.email
    assert_match /Repying to see how this thing works/m, replaced_email
    assert_no_match /Status: New/, replaced_email
  end

  def test_remove_reply_thread_jimmy
    raw_email = get_mail_sample :jimmy_mac_reply
    email = Mail.new(raw_email.to_s)

    normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
    normalized_email.remove_nonhtml_text!
    normalized_email.clean_format!
    normalized_email.remove_thread!
    #normalized_email.embed_images!

    replaced_email = normalized_email.email
    assert_match /first=\r?\n reply from MacMail/m, replaced_email
    #assert_no_match /Status/, replaced_email
  end

  def test_embed_image
		raw_email = get_mail_sample :macmail_embedded_image
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email		
		normalized_email.embed_images!

		replaced_email = normalized_email.email
		assert_match /\!chili.jpeg\!/i, replaced_email
		assert_no_match /src="cid:15E20329-A453-400D-97BC-FEF347190C0D"/i, replaced_email
		assert_no_match /Content-Disposition: inline/i, replaced_email
		assert_match /Content-Disposition: attachment/i, replaced_email
	end

	def test_move_inline_multiple_attachments_no_body		
		raw_email = get_mail_sample :macmail_multiple_attachments_with_no_body
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email		
		normalized_email.embed_images!

		replaced_email = normalized_email.email
		assert_no_match /Content-Disposition: inline/i, replaced_email
		assert_match /Content-Disposition: attachment/i, replaced_email
	end

# TMail only processes attachments if they aren't nested in other parts  
	def test_move_all_attachment_parts_to_root
		raw_email = get_mail_sample :macmail_multiple_inline_images
		
		tmail_email = TMail::Mail.parse(raw_email)
		assert_equal false, tmail_email.has_attachments?

		email = Mail.new(raw_email.to_s)
		assert_equal 2, email.parts.length

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email		
		normalized_email.embed_images!

		replaced_email = normalized_email.email
		tmail_email = TMail::Mail.parse(replaced_email)
		assert_equal true, tmail_email.has_attachments?
		assert_equal 2, tmail_email.attachments.length

		email = Mail.new(replaced_email)
		assert_equal 4, email.parts.length
	end


=begin
  Test borken after chili 3.7 upgrade
	def test_remove_plain_text
  		raw_email = get_mail_sample :macmail_simple_email
	  	email = Mail.new(raw_email.to_s)

	  	normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
	  	normalized_email.remove_nonhtml_text!

		  replaced_email = normalized_email.email
		  assert_no_match /text\/plain/, replaced_email
	end
=end

	def test_keep_all_other_parts_on_remove_plain_text
		raw_email = get_mail_sample :macmail_embedded_image
		email = Mail.new(raw_email.to_s)

		normalized_email = EnhancedIncomingMail::NormalizedMacMailEmail.new email
		normalized_email.remove_nonhtml_text!

		replaced_email = normalized_email.email
		assert_no_match /text\/plain/, replaced_email
		assert_match /text\/html/i, replaced_email
		assert_match /image\/jpg/i, replaced_email
	end

	# def test_outlook_remove_thread
	# 	raw_email = get_mail_sample :outlook_reply

	# 	replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_thread email

	# 	assert_match /(?!>)New comment added from Outlook(?!<)/m, replaced_email
	# 	assert_match />New comment added from Outlook</m, replaced_email
	# 	assert_no_match /R(=\r\n)?E(=\r\n)?M(=\r\n)?O(=\r\n)?V(=\r\n)?E(=\r\n)?D/m, replaced_email
	# end

=begin
	def test_remove_outlook_plain_text
		raw_email = get_mail_sample :outlook_simple_email

		replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_nonhtml_text email

		assert_match /text\/html/, replaced_email
		assert_no_match /text\/plain/, replaced_email
	end

	def test_dont_remove_macmail_plain_text_if_no_html
		raw_email = get_mail_sample :macmail_plain_text_only_email

		replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_nonhtml_text email

		assert_match /text\/plain/, replaced_email
	end

	def test_dont_remove_outlook_plain_text_if_no_html
		raw_email = get_mail_sample :outlook_plain_text_only_email

		replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_nonhtml_text email

		assert_match /text\/plain/, replaced_email
	end

	def test_dont_remove_macmail_inline_image
		raw_email = get_mail_sample :macmail_inline_image_email

		replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_nonhtml_text email

		# Verify headers are kept
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*Content-Transfer-Encoding: base64.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*Content-Disposition: inline.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*Content-Type: image\/jpg.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*Content-Id: <7E19788E-1953-4E0D-8CBB-57C242618F62>.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email

		# Verify image content is kept
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*\/9j\/4AAQSkZJRgABAQAAAQABAAD\/\/gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*SlBFRyB2NjIpLCBxdWFsaXR5ID0gOTAK\/9sAQwADAgIDAgIDAwMDBAMDBAUIBQUEBAUKBwcGCAwK.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email
		assert_match /--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E.*DAwLCgsLDQ4SEA0OEQ4LCxAWEBETFBUVFQwPFxgWFBgSFBUU\/9sAQwEDBAQFBAUJBQUJFA0LDRQU.*--Apple-Mail=_F45C7FA0-4316-4761-9CB8-A543BDD9884E--/m, replaced_email
	end

	def test_dont_remove_outlook_inline_image
		raw_email = get_mail_sample :outlook_inline_image_email

		replaced_email = EnhancedIncomingMail::NormalizeEmail.remove_nonhtml_text email

		# Verify headers are kept
		assert_match /------=_NextPart_001_16A9_9AAE5176.5DDD27B3.*Content-Disposition: attachment.*------=_NextPart_001_16A9_9AAE5176.5DDD27B3--/m, replaced_email
		assert_match /------=_NextPart_001_16A9_9AAE5176.5DDD27B3.*Content-Transfer-Encoding: base64.*------=_NextPart_001_16A9_9AAE5176.5DDD27B3--/m, replaced_email

		# Verify image content is kept
		assert_match /------=_NextPart_001_16A9_9AAE5176.5DDD27B3.*\/9j\/4AAQSkZJRgABAQAAAQABAAD\/\/gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg.*------=_NextPart_001_16A9_9AAE5176.5DDD27B3--/m, replaced_email
		assert_match /------=_NextPart_001_16A9_9AAE5176.5DDD27B3.*SlBFRyB2NjIpLCBxdWFsaXR5ID0gOTAK\/9sAQwADAgIDAgIDAwMDBAMDBAUIBQUEBAUKBwcGCAwK.*------=_NextPart_001_16A9_9AAE5176.5DDD27B3--/m, replaced_email
		assert_match /------=_NextPart_001_16A9_9AAE5176.5DDD27B3.*dxTWoooAU9\/pSjrRRQAg60q0UUAf\/9k=.*------=_NextPart_001_16A9_9AAE5176.5DDD27B3--/m, replaced_email
	end
=end

end