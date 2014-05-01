require File.expand_path('../../test_helper', __FILE__)

module TipitExtensions

  class BouncedDeliveryTest <  ActiveSupport::TestCase
    include TipitExtensionHelper

    def test_should_detect_final_recipient()
      email = TMail::Mail.parse(get_mail_sample :bounced_issue)
      bounced_delivery = BouncedDelivery.from_email(email)

      assert_equal 'nobody@tipit.net', bounced_delivery.final_recipient
    end

    def test_should_detect_issue_id()
      email = TMail::Mail.parse(get_mail_sample :bounced_issue)
      bounced_delivery = BouncedDelivery.from_email(email)

      assert_equal 1873, bounced_delivery.issue_id
    end

  end

end
