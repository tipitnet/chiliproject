require File.expand_path('../../test_helper', __FILE__)

class MailNormalizatorFactoryTest < Test::Unit::TestCase
	include Helper

  context "create_mail_normalized" do
  	should " create_normalized_mac_mail" do
	  	raw_email = get_mail_sample :macmail_reply

		  normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

		  assert_not_nil normalizator
		  assert normalizator.class.name == "EnhancedIncomingMail::NormalizedMacMailEmail"
	  end

    should 'create_normalized_outlook' do
		  raw_email = get_mail_sample :outlook_reply

		  normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

		  assert_not_nil normalizator
		  assert normalizator.class.name == "EnhancedIncomingMail::NormalizedOutlookEmail"
	  end
  end

=begin
	def test_create_normalized_gmail
		raw_email = get_mail_sample :gmail_reply

		normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

		assert_not_nil normalizator
		assert normalizator.class.name == "EnhancedIncomingMail::NormalizedGmailEmail"
	end

	def test_create_normalized_postbox
		raw_email = get_mail_sample :postbox_reply

		normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

		assert_not_nil normalizator
		assert normalizator.class.name == "EnhancedIncomingMail::NormalizedPostboxEmail"
	end

	def test_throws_when_invalid_raw_mail
		assert_raise EnhancedIncomingMail::RawEmailError do 
			EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized nil
		end

		assert_raise EnhancedIncomingMail::RawEmailError do 
			EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized ''
		end
	end

  def test_create_normalized_zimbra
    raw_email = get_mail_sample :zimbra_reply

    normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

    assert_not_nil normalizator
    assert normalizator.class.name == "EnhancedIncomingMail::NormalizedZimbraEmail"
  end
=end
end