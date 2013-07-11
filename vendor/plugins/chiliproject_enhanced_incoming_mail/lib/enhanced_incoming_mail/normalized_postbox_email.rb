module EnhancedIncomingMail
	class NormalizedPostboxEmail < NormalizedGenericEmail
		def initialize(email)
			super(email)
		end

    def self.identifier
      :postbox
    end

		def get_reply_identifier_pattern
			"WHEN REPLYING, DO NOT ADD TEXT BELOW THIS LINE"
    end

    def replace_consecutive_lb_and_bs(html_body)
    end

	end
end