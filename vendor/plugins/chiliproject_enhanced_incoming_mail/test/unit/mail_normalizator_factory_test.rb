require File.expand_path('../../test_helper', __FILE__)

class MailNormalizatorFactoryTest < ActiveSupport::TestCase
	include Helper

	def test_create_normalized_mac_mail
		raw_email = get_mail_sample :macmail_reply

		normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

		assert_not_nil normalizator
		assert normalizator.class.name == "EnhancedIncomingMail::NormalizedMacMailEmail"
	end

	def test_create_normalized_outlook
		raw_email = get_mail_sample :outlook_reply

		normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

		assert_not_nil normalizator
		assert normalizator.class.name == "EnhancedIncomingMail::NormalizedOutlookEmail"
	end

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
    raw_email = get_mail_sample :zimbra_7_2_0_reply

    normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email

    assert_not_nil normalizator
    assert normalizator.class.name == "EnhancedIncomingMail::NormalizedZimbraEmail"
  end

  def test_create_normalized_outlook_case_2
    raw_email = get_mail_sample :outlook_case_2
    normalizator = EnhancedIncomingMail::MailNormalizatorFactory.create_mail_normalized raw_email
    assert_not_nil normalizator
    assert normalizator.class.name == "EnhancedIncomingMail::NormalizedOutlookEmail"
  end

end