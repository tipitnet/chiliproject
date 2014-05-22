require_dependency 'mail_handler'

module TipitExtensions

  module MailHandlerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        alias_method_chain :receive_issue, :tipit_patch
        alias_method_chain :receive, :tipit_patch
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      attr_accessor :bounced_delivery

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

      def get_email_client_type(email)
        #EnhancedIncomingMail::MailNormalizatorFactory.get_email_client_type(email)
        'generic'
      end

      def receive_with_tipit_patch(email)
        begin
          if email.content_type == 'multipart/report'
            @bounced_delivery = BouncedDelivery.from_email(email)
            received_mail_logger.debug "Bounced email detected. Issue:#{@bounced_delivery.issue_id}. Final recipient:#{@bounced_delivery.final_recipient}."
            issue = Issue.find_by_id(@bounced_delivery.issue_id)
            remove_issue_watcher(issue, @bounced_delivery.final_recipient) unless issue.nil?
            received_mail_logger.debug "Bounced email processed"
            return true
          end

          result = true

          received_mail_logger.info "Email received processing start: #{email.from.to_s}, #{email.subject}"

          received_mail_logger.debug "Email client detection start"
          user_agent = get_email_client_type(email)
          received_mail_logger.debug "Email client detection completed: #{user_agent}"

          #received_mail_logger.info "Raw mail > #{email.to_s}\r\n"

          received_mail_logger.debug "Recipients validation start"
          if valid_recipients(email)
            received_mail_logger.debug "Recipients validation completed: valid"
            received_mail_logger.debug "Native method receive start"
            result = receive_without_tipit_patch(email)
            received_mail_logger.debug "Native method receive completed: #{result}."
          else
            received_mail_logger.debug "Recipients validation completed: not valid"
          end
          return result
        rescue Exception => e
          received_mail_logger.debug "Mail processing failed. Check Rails log file"
          Rails.logger.error(e)
          raise e
        end
      end

      def valid_recipients(email)
        result = true
         if email.to.size > 1 || !email.cc.nil?
           Mailer.deliver_issue_reject_to(email.from, email.subject)
           result = false
         end
        result
      end

      def remove_issue_watcher(issue, user_email)
        user = User.find_by_mail(user_email)
        if user.nil?
          watcher = Watcher.first(:conditions => {
              :user_id => EmailWatcherUser.default.id,
              :watchable_type => 'Issue',
              :watchable_id => issue.id
          })
          watcher.email_watchers.delete(user_email)
          watcher.save
        else
          issue.remove_watcher(user)
        end
      end


      # This method is in the chain but it interrupt because it replaces the original method
      def receive_issue_with_tipit_patch
        received_mail_logger.debug 'Entering receive_issue_with_tipit_patch'
        project = target_project

        received_mail_logger.debug "preliminar target_project: #{project}"
        
        if project.identifier == 'undefined-project'
          default_project_name = user.custom_value_for(CustomField.find_by_name('Default Project'))
          default_project_name = (default_project_name.nil? || default_project_name.to_s.empty?) ? 'inbox' : default_project_name.to_s
          project = Project.find_by_identifier(default_project_name)
        end

        # check permission, TODO: validate if this is required
        #unless @@handler_options[:no_permission_check]
        #  raise UnauthorizedAction unless user.allowed_to?(:add_issues, project)
        #end

        issue = Issue.new(:author => user, :project => project)
        issue.safe_attributes = issue_attributes_from_keywords(issue)
        issue.safe_attributes = {'custom_field_values' => custom_field_values_from_keywords(issue)}
        issue.subject = email.subject.to_s.chomp[0,255]
        if issue.subject.blank?
          issue.subject = '(no subject)'
        end
        issue.description = cleaned_up_text_body

        # add To and Cc as watchers before saving so the watchers can reply to Redmine
        received_mail_logger.debug "Adding watchers start"
        add_watchers(issue)
        add_default_watchers(issue)
        issue.save!
        if user.anonymous?
          email_watcher_address = email.from.to_s
          watcher = Watcher.new()
          watcher.email_watchers = []
          watcher.email_watchers << email_watcher_address
          watcher.watchable = issue
          watcher.user = EmailWatcherUser.default
          watcher.save
            Mailer.deliver_issue_add(issue,email_watcher_address)
        end
        received_mail_logger.debug "Adding watchers completed"
        received_mail_logger.debug "Adding attachments start"
        add_attachments(issue)
        received_mail_logger.debug "Adding attachments completed"

        logger.info "MailHandler: issue ##{issue.id} created by #{user}" if logger && logger.info
        received_mail_logger.info "Email received processing completed: Issue ##{issue.id} created by #{user} \r"

        if !user.anonymous?
         Mailer.deliver_mail_handler_confirmation(issue, user, issue.subject) if Setting.mail_handler_confirmation_on_success?
        end

        issue
      end

      def add_default_watchers(issue)
        received_mail_logger.debug "Entering add_default_watchers"
        default_watchers = issue.get_default_watchers
        default_watchers = default_watchers.gsub(/\s+/, "")
        received_mail_logger.debug "Default watchert to add [#{default_watchers}]"
        default_watchers_list = default_watchers.split(',')
        default_watchers_list.each do | watcher_login |
          watcher = User.find_by_login(watcher_login)
          issue.add_watcher(watcher)
        end
        received_mail_logger.debug "Exiting add_default_watchers"
      end

    end

  end

end