module EnhancedIncomingMail
		
	class NormalizedMacMailEmail < NormalizedEmail
		def initialize(email)
			super(email)
		end

    def self.identifier
      :mac_mail
    end

		def get_reply_identifier_pattern
      # other option could be match blockquote
      "WHEN REPLYING, DO NOT ADD TEXT BELOW THIS LINE"
		end

		# Reply mails' HTML from Mac Mail should be of the form
		# <body>
		# 	<!-- Reply content -->
		#   <br>
		#   <div>
		#   	<div>On 01/01/2001...</div>
		#     <blockquote>
		# 			WHEN REPLYING, DO NOT ADD TEXT BELOW THIS<br/>
		#       <!-- Quoted content -->
		#     </blockquote>
		#   </div>
		#  <!-- ... -->
		def strip_reply_from_html_part(message)
			html_doc = Nokogiri::HTML(message.body.decoded)
			
			first_blockquote = html_doc.xpath("//blockquote").first
			if !first_blockquote
				Rails.logger.error("Could not strip reply from email, <blockquote> element not found.\n\t#{message.body.to_s}")
				return
			end

			#first_blockquote.parent.remove or first_blockquote.previous_sibling.remove
      first_blockquote.remove
			set_html_body(message, html_doc.to_s)
		end

	end

end