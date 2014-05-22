module EnhancedIncomingMail
	class NormalizedGmailEmail < NormalizedEmail
		def initialize(raw_email)
			super(raw_email)
		end

    def self.identifier
      :gmail
    end

  	def replace_unsupported_html_tags(html_body)
  		font_size_replacements = {'6' => { :heading => 'h1' },
								  						  '4' => { :heading => 'h2' },
								  						  '1' => :remove }

  		html_doc = Nokogiri::HTML(html_body)
      html_doc.encoding='utf-8'

  		for font_tag in html_doc.xpath("//font")
  			next if font_tag.attr('size').nil?

				font_size_replacement = font_size_replacements[font_tag.attr('size')]
				new_parent = nil
				if font_size_replacement
					if font_size_replacement == :remove
						new_parent = font_tag.parent
					else
							header_tag = Nokogiri::XML::Node.new(font_size_replacement[:heading], html_doc)
						font_tag.add_next_sibling(header_tag)
						new_parent = header_tag
					end
				end

				font_tag.children.each{|c| c.parent = new_parent }
				font_tag.remove
  		end

      html_doc.to_s.empty? ? super(html_doc.text) : super(html_doc.to_s)
    end

		def get_reply_identifier_pattern
			return "On.+?wrote:"
		end


		# Reply mails' HTML from GMail should be of the form
		# <body>
		# 	<!-- Reply content -->
		#   <br>
		#   	<div class="gmail_quote">On Mon, Jul 23, 2012...
		#       <blockquote class="gmail_quote">
		# 			  WHEN REPLYING, DO NOT ADD TEXT BELOW THIS<br/>
		#         <!-- Quoted content -->
		#       </blockquote>
		#     </div>
		#  <!-- ... -->
		def strip_reply_from_html_part(message)
			html_doc = Nokogiri::HTML(message.body.decoded)

      html_doc.encoding='utf-8'

			reply_div = html_doc.at_css('div.gmail_quote')
			if !reply_div
        received_mail_logger.error("Could not strip reply from email, <div class'gmail_quote'> element not found.\n\t#{message.body.to_s}")
        # this is a hack for mails with strange chars
        plain_body = message.body.decoded.split('WHEN REPLYING, DO NOT ADD TEXT BELOW THIS LINE')[0]
        set_html_body(message,plain_body)
				return
			end

			reply_content = reply_div.next
			while !reply_content.nil?
				reply_content.remove
				reply_content = reply_div.next
			end

			reply_div.remove

      final_body = html_doc.to_s.empty? ? html_doc.text : html_doc.to_s

			set_html_body(message, final_body)
		end
	end
end