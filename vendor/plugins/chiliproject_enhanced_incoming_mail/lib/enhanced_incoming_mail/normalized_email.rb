module EnhancedIncomingMail

  class ReplyIdentifierNotFoundError < EnhancedIncomingMailError
  end

  class EmbeddedImageNotFoundError < EnhancedIncomingMailError
  end

  class NormalizedEmail

    def received_mail_logger
      @@tipit_logger ||= create_logger
    end

    def create_logger
      tipit_logger = Logger.new("#{Rails.root}/log/received_emails.log", "daily")
      tipit_logger.level = Logger::DEBUG
      tipit_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} [#{datetime}] - #{progname}: #{msg}\n"
      end
      tipit_logger
    end

    def initialize(email)
      if !email
        raise ArgumentError, "'email' argument cannot be nil"
      end

      @email = email
    end

    def email
      @email.to_s
    end

  # -----------------------------------------------------------------------------------------------------------------------------------------------
  # normalize ChiliProject supported HTML tags
  # -----------------------------------------------------------------------------------------------------------------------------------------------
    def clean_format!()
      if !@email.html_part
        return @email.to_s
      end

      html_body = replace_unsupported_html_tags(@email.html_part.body.decoded)
    
      set_html_body(@email, html_body)

      email
    end


  # -----------------------------------------------------------------------------------------------------------------------------------------------
  # replace IMG tags with image reference (e.g. !image.gif!)
  # -----------------------------------------------------------------------------------------------------------------------------------------------
    def embed_images!
      if !@email.multipart?
        return email
      end

    # replace image tags if HTML part(s) present
      html_parts = get_parts_by_content_type(@email.parts, '^text/html;')
      if html_parts && html_parts.length > 0
        image_parts = get_parts_by_content_type(@email.parts, 'image/.+?;?$')
        for html_part in html_parts
          replace_image_tags(html_part, image_parts)
        end
      end

    # TODO - remove this hack (inline attachments should be processed by Chili's MailHandler)
    # transform inline attachments into regular ones, otherwise TMail will return false on email.has_attachments?
      move_inline_attachments(@email.parts)

      email
    end

  # -----------------------------------------------------------------------------------------------------------------------------------------------
  # remove non-HTML text blocks if HTML is available
  # -----------------------------------------------------------------------------------------------------------------------------------------------
    def remove_nonhtml_text!()     
    # check if HTML content is available, otherwise plain text must be kept
      if !@email.html_part
        return email
      end

      remove_plain_text_parts(@email)

      email
    end

  # -----------------------------------------------------------------------------------------------------------------------------------------------
  # remove thread portion of email text
  # -----------------------------------------------------------------------------------------------------------------------------------------------
    def remove_thread!()
      if !@email.header[:in_reply_to]
        return email
      end

      reply_pattern = get_reply_pattern
      
      if @email.multipart?
        @email.parts.each do |p|
          remove_reply_from_part(p, reply_pattern)
        end

        remove_unreferenced_inline_images
      end

      email
    end

    # sets the body encoded content 
    def set_html_body(message, html_body)
      if message.header[:content_type].value !~ /text\/html/i && message.multipart? && message.html_part
        message = message.html_part
      end

      html_body_encoding = Mail::Encodings.get_encoding(message.body.encoding)
      message.body = html_body_encoding.encode(html_body.to_s)
    end

    def replace_unsupported_html_tags(html_body)
      EnhancedIncomingMail::TextileConverter.new(html_body).to_textile
    end

  private

    def get_reply_pattern
      return ".+?(#{get_reply_identifier_pattern}.+)"
    end

    def get_reply_identifier_pattern
      raise NotImplementedError
    end

    def strip_reply_from_html_part(message)
      raise NotImplementedError
    end

    def remove_reply_from_part(part, reply_pattern)
      if part.multipart?
        part.parts.each do |p|
          remove_reply_from_part(p, reply_pattern)
        end
      else
        match_result = part.body.decoded.match(Regexp.new(reply_pattern, Regexp::MULTILINE|Regexp::IGNORECASE))
        if match_result
          if part.content_type =~ /text\/html/i
            strip_reply_from_html_part(part)
          else
            part.body = part.body.decoded.gsub(match_result[1], '')
          end
        end
      end
    end

  # removes recursively plain text parts
    def remove_plain_text_parts(message)
      message.parts.delete_if {|p| p.content_type =~ /text\/plain/i }

      for part in message.parts
        remove_plain_text_parts(part)
      end
    end

    def remove_unreferenced_inline_images
      html_parts = get_parts_by_content_type(@email.parts, '^text/html;')
      image_cids = html_parts.inject([]) { |cids, hp| cids.concat(hp.body.decoded.scan(/<img.+?src=['"]cid:(.+?)['"].+?/mi).flatten) }

      delete_image_parts(@email, image_cids)
    end

    def delete_image_parts(message, referenced_image_parts)
      message.parts.delete_if do |p| 
        delete_image_part = false
        if p.content_type =~ /image\/.+?;?$/
          content_id = get_image_cid_from_header(p).gsub!('<', '').gsub!('>', '')
          delete_image_part = !referenced_image_parts.include?(content_id)
        end

        delete_image_part
      end

      for part in message.parts
        delete_image_parts(part, referenced_image_parts)
      end
    end

    def replace_image_tags(html_part, image_parts)
      html_body = html_part.body.decoded
      image_tags = html_body.scan(/<img.+?cid:.+?>/mi)
      if !image_tags
        return
      end

      if !image_tags.nil? and image_tags.length > 0 and !image_parts
        raise EmbeddedImageNotFoundError, "Referenced embedded images not found:\n\t#{image_tags.to_s}"
      end

      for i in (0..image_tags.length - 1)
        image_tag = image_tags[i]
        if image_tag.match(/src=['"](cid:)?(.+?)['"]/i).length != 3
          raise EmbeddedImageNotFound, "Embedded image ID could not be extracted from:\n\t#{image_tag}"
        end

        image_tag_source = image_tag.match(/src=['"](cid:)?(.+?)['"]/i)[2]
        # From ControllerMailHandlerNewBeforeSaveHook:
        # mask a problem with TMAIL and Microsoft Entourage generated mail. TMAIL drops the content header declaration 'Content-Id'
        referenced_image_part = image_parts.find{ |ip| get_image_cid_from_header(ip) =~ Regexp.new(image_tag_source, Regexp::MULTILINE|Regexp::IGNORECASE) }

        if !referenced_image_part
          raise EmbeddedImageNotFoundError, "Referenced image part not found:\n\t#{image_tag_source}"
        end

        # TMail reads 'name' parameter on content-type header (and not 'filename')
        if referenced_image_part.filename.blank?
          referenced_image_part.header[:content_type].parameters['name'] = get_image_name_from_cid(image_tag_source, referenced_image_part.header[:content_type])
        end

        html_body.gsub!(image_tag, "!#{referenced_image_part.header[:content_type].filename}!")
      end

      set_html_body(html_part, html_body)
    end

    def move_inline_attachments(parts)
      parts_to_remove = []

      #for part in parts
      parts.each do | part |
      # Content-Disposition header is optional for attachments (parts with content type different to multipart/* and text/*),
      # so if not present we add the header
        if !part.header[:content_disposition] && part.content_type !~ /(multipart\/|text\/)/i
          part.headers({ :content_disposition => 'attachment' })
        end

        if part.header[:content_disposition]

          if part.header[:content_disposition].value =~ /inline/i
            raw_content_disposition_field = part.header[:content_disposition].encoded
            raw_content_disposition_field.gsub!(/inline/i, 'attachment')
            part.header[:content_disposition].value = 'attachment'
            #part.header[:content_disposition] = Mail::ContentDispositionField.new(raw_content_disposition_field, part.header[:content_disposition].charset)
          end

          if @email.parts != parts
            parts_to_remove << part.hash
            @email.add_part(part)
          end
        end

        move_inline_attachments(part.parts) unless part.parts.length == 0
      end

    # nested parts are removed outside the loop
      if parts_to_remove.length > 0
        parts.delete_if {|p| parts_to_remove.include?(p.hash) }
      end
    end

  # looks recursively on the parts tree for all parts of the given content-type
    def get_parts_by_content_type(parts_collection, content_type)
      matching_parts = []
      for part in parts_collection
        if part.content_type =~ Regexp.new(content_type, Regexp::IGNORECASE)
          matching_parts << part
        end
        if part.respond_to?(:parts) && !part.parts.empty?
          matching_parts.concat(get_parts_by_content_type(part.parts, content_type))
        end
      end

      matching_parts
    end

    def get_image_cid_from_header(image_part)
      case
      when !image_part.header['Content-Id*'].nil?
        image_part.header['Content-Id*'].value
      when !image_part.header[:content_id].nil?
        image_part.header[:content_id].value
      else
        nil
      end
    end

    def get_image_name_from_cid(cid, content_type_field)
      filename = (cid.include?("@") ? cid[0..cid.index("@")-1] : cid).gsub('.', '_')

      mime_type = MIME::Types[content_type_field.value].first
      extension = mime_type.extensions.first

      return "#{filename}.#{extension}"
    end
  end

end


#def replace_unsupported_html_tags(html_body)
#  # cleanup carriage returns and space characters
#  html_body.gsub!(/\n/, "")
#  html_body.gsub!(/<p>/, "")
#  html_body.gsub!(/<\/p>/, "\n")
#  html_body.gsub!(/<div>/, "\n")
#  html_body.gsub!(/<br>/, "\n")
#  html_body.gsub!(/&nbsp; /, " ")
#  html_body.gsub!(/&nbsp;/, " ")
#
#  # replace html tags (e.g. Bold, Italic, Underline, and Delete) with Chiliproject allowable tags
#  tag_replacements = [{:tag => "b", :replacement => "*"},
#                      {:tag => "strong", :replacement => "*"},
#                      {:tag => "i", :replacement => "_"},
#                      {:tag => "em", :replacement => "_"},
#                      {:tag => "ins", :replacement => "+"},
#                      {:tag => "u", :replacement => "+"},
#                      {:tag => "del", :replacement => "-"},
#                      {:tag => "cite", :replacement => "??"}]
#
#  tag_replacements.each { | x |
#    html_body.gsub!(Regexp.new('<(' + x[:tag] + ')>(.+?)</(' + x[:tag] + ')>', Regexp::MULTILINE|Regexp::IGNORECASE),
#                    "#{x[:replacement]}\\2#{x[:replacement]}")
#  }
#
#  # remove <TITLE> </TITLE> tag entry if present (Mac Mail inserts this in the body of text)
#  title_tag_pattern = "<title>(.+?)</title>"
#  html_body.gsub!(Regexp.new(title_tag_pattern, Regexp::MULTILINE|Regexp::IGNORECASE), "")
#
#  # replace heading html tags
#  heading_tags = [ "h1", "h2", "h3"]
#  heading_tags.each { | h |
#    html_body.gsub!(Regexp.new('<(' + h + ')>(.+?)</(' + h + ')>', Regexp::MULTILINE|Regexp::IGNORECASE),
#                    "\n#{h}. \\2\n")
#  }
#
#  # replace links
#  html_body.gsub!(Regexp.new('<a.*?href=["\'](.*?)["\'].*?>(.+?)</a>', Regexp::MULTILINE|Regexp::IGNORECASE),
#                  "\"\\2\":\\1")
#
#  # replace lists
#  list_replacements = [{:list_tag => 'ul', :replacement => '*'},
#                       {:list_tag => 'li', :replacement => '#'}]
#  for list_replacement in list_replacements
#    lists = html_body.scan(/\<#{list_replacement[:list_tag]}\>.+?\<\/#{list_replacement[:list_tag]}\>/mi)
#    lists.each { |l|
#      replaced_list = l.gsub('<li>', "#{list_replacement[:replacement]}").gsub('</li>', '').gsub(/\<\/?#{list_replacement[:list_tag]}\>/i, '')
#      html_body.gsub!(l, replaced_list)
#    } unless lists.nil?
#  end
#
#  # replace consecutive end of lines which are transformed into <pre> blocks by Chili
#  replace_consecutive_lb_and_bs(html_body)
#
#  html_body
#end
#
#def replace_consecutive_lb_and_bs(html_body)
#  #html_body.gsub!(/[\n ]{2,}/m, "\n")
#end
