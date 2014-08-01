class EmailAttachment < Attachment

  attr_accessor :file_name, :file_content

  def before_save
    if @temp_file && (@temp_file.size > 0)
      logger.debug("saving '#{self.diskfile}'")
      md5 = Digest::MD5.new
      File.open(diskfile, "wb") do |f|
        f.write(file_content)
        md5.update(file_content)
      end
      self.digest = md5.hexdigest
    end
    # Don't save the content type if it's longer than the authorized length
    if self.content_type && self.content_type.length > 255
      self.content_type = nil
    end
  end

end