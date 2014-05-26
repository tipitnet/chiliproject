module EnhancedIncomingMail

	class NormalizedZimbraEmail < NormalizedGenericEmail
		def initialize(raw_email)
			super(raw_email)
		end

    def self.identifier
      :zimbra
    end

    def get_reply_identifier_pattern
      "WHEN REPLYING, DO NOT ADD TEXT BELOW THIS LINE"
    end

    def replace_unsupported_html_tags(html_body)
      html_body = super(html_body)

      html_doc = Nokogiri::HTML(html_body)
      head = html_doc.xpath("//head").first
      if head
        head.remove
      end

      html_doc.to_s

    end
  end

end

