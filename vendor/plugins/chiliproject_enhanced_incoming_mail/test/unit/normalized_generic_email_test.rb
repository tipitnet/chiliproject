require File.expand_path('../../test_helper', __FILE__)

class NormalizedGenericEmailTest < Test::Unit::TestCase
	include Helper

	def test_remove_reply_thread
    # we are using thunderbird as generic
		raw_email = get_mail_sample :thunderbird_reply
		email = Mail.new(raw_email.to_s)
		normalized_email = EnhancedIncomingMail::NormalizedGenericEmail.new email
    normalized_email.remove_nonhtml_text!()

		normalized_email.remove_thread!

		replaced_email = normalized_email.email
		assert_match /First comment/, replaced_email
    assert_no_match /Priority: Normal/, replaced_email

	end

end