module EnhancedIncomingMail
  	
  	# Used for unspecific email clients
	class NormalizedGenericEmail < NormalizedEmail
		def initialize(raw_email)
			super(raw_email)
		end

    def self.identifier
      :other
    end

    def get_reply_identifier_pattern
      "On.+?wrote:"
    end

    # In a general case mails in HTML should be of the form
    # <body>
    # 	<!-- Reply content -->
    #   <br>
    #   <blockquote>
    #     <!-- Quoted content -->
    #  	</blockquote>
    #  <!-- ... -->
    def strip_reply_from_html_part(message)
      html_doc = Nokogiri::HTML(message.body.decoded)
      blockquote = html_doc.xpath("//blockquote").first
      if !blockquote
        Rails.logger.error("Could not strip reply from email, <blockquote> element not found.\n\t#{message.body.to_s}")
        return
      end

      blockquote.remove

      set_html_body(message, html_doc.to_s)
    end

  end

end

