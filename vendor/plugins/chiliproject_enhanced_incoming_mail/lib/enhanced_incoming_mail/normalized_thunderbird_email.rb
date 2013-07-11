module EnhancedIncomingMail

	class NormalizedThunderbirdEmail < NormalizedGenericEmail
		def initialize(raw_email)
			super(raw_email)
		end

    def self.identifier
      :thunderbird
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
      # remove the thread using the generic logic
      super(message)

      #remove the cite
      html_doc = Nokogiri::HTML(message.body.decoded)
      cite_div = html_doc.at_css('div.moz-cite-prefix')

      if cite_div
        cite_div.remove
      end

      set_html_body(message, html_doc.to_s)
    end

  end

end

