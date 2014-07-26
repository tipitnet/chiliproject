module AttachmentPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
  end

  module InstanceMethods

    def file_from_mail=(incoming_file)
      unless incoming_file.nil?
        @temp_file = incoming_file
        self.filename = sanitize_filename(@temp_file.filename)
        self.disk_filename = Attachment.disk_filename(filename)
        self.content_type = @temp_file.content_type.to_s.chomp
        if content_type.blank?
          self.content_type = Redmine::MimeType.of(filename)
        end
        self.filesize = @temp_file.size
      end
    end

  end
end
