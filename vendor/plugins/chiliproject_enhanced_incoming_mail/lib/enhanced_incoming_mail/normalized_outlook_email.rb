module EnhancedIncomingMail
  	
	class NormalizedOutlookEmail < NormalizedEmail
		def initialize(raw_email)
			super(raw_email)
		end

    def self.identifier
      :ms_outlook
    end

    # Reply mails' HTML from Outlook should be of the form
		# <body>
		# 	<!-- Reply content -->
		#   <br>
		#   <div>
		#   	<div style="border:none;border-top:solid #B5C4DF 1.0pt;padding:3.0pt 0cm 0cm 0cm">
		# 			<p class="MsoNormal">
		# 				<b><span>From:</span></b>
		# 				<span>chiliproject@dev.chili.tipit.net [mailto:chiliproject@dev.chili.tipit.net]
		# 				...
		# 		</div>
		# 		<div id="issue_details">
		# 			WHEN REPLYING, DO NOT ADD TEXT BELOW THIS<br/>
		#     	<!-- Quoted content -->
		# 			...
		# 		</div>
		def strip_reply_from_html_part(message)
			html_doc = Nokogiri::HTML(message.body.decoded)
			issue_details = html_doc.css("#issue_details").first
			if !issue_details
				Rails.logger.error("Could not strip reply from email, <div> with ID issue_details not found.\n\t#{message.body.to_s}")
      	return
			end

			# remove everything below the reply DIV
			reply_content = issue_details.next
			while !reply_content.nil?
				reply_content.remove
				reply_content = issue_details.next
			end

			issue_details.remove
			original_email_details = html_doc.xpath("//div[contains(@style, 'border-top:solid #B5C4DF')]")
			if !original_email_details.nil?
				original_email_details.remove
			else
				Rails.logger.warn("Could not strip original mail details.\n\t#{message.body.to_s}")
			end

			set_html_body(message, html_doc.to_s)
		end

		def get_reply_identifier_pattern
			return "From:.*\\[mailto:\\s*[a-z0-9._%-]+@[a-z0-9.-]+\\.[a-z]{2,4}\\]"
		end
	end

end