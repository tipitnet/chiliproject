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

    def strip_reply_from_html_part(message)
      html_doc = Nokogiri::HTML(message.body.decoded)

      hr = html_doc.css('hr#zwchr').first

      if hr
        hr.xpath('following-sibling::*').remove
        hr.remove
      else
        Rails.logger.warn("Could not strip reply from email using hr#zwchr, trying with <blockquote>.\n\t#{message.body.to_s}")

        blockquote = html_doc.xpath('//blockquote').first

        unless blockquote
          Rails.logger.error("Could not strip reply from email, <blockquote> element not found.\n\t#{message.body.to_s}")
          return
        end

        blockquote.remove
      end

      set_html_body(message, html_doc.to_s)
    end

    def replace_unsupported_html_tags(html_body)
      html_body = super(html_body)

      html_doc = Nokogiri::HTML(html_body)
      head = html_doc.xpath('//head').first
      if head
        head.remove
      end

      html_doc.to_s
    end

  end

end