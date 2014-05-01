require_dependency 'issue'

module TipitExtensions

  module IssuePatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method_chain :recipients, :tipit_patch
        before_save :before_save
      end

    end

    module ClassMethods

    end

    module InstanceMethods

      def before_save
        add_asignee_as_watcher
        add_updater_as_watcher
        set_start_date
      end

      def is_watcher?(user)
        if(self.new_record?)
          return self.get_default_watchers().include?(user.login)
        else
          return self.watched_by(user)
        end
      end

      def get_default_watchers()
        begin
          default_watchers_field = CustomField.find_by_name('Default watchers')
          return "" if default_watchers_field.nil?
          default_watchers = project.custom_value_for(default_watchers_field)
          if (default_watchers.nil?)
            result = ""
          else
            result = default_watchers.value.downcase
          end
          result
        rescue
          return ""
        end
      end


      def add_asignee_as_watcher
        if (self.changes.include?('assigned_to_id'))
          return if self.assigned_to.nil?
          is_already_watching = self.watched_by?(self.assigned_to)
          if(!is_already_watching)
            self.set_watcher(self.assigned_to, true)
          end
        end
      end

      def add_updater_as_watcher
        return if self.current_journal.nil?
        is_already_watching = self.watched_by?(self.current_journal.user)
        if(!is_already_watching)
          nowatcher = Nowatcher.all(:conditions => "user_id=#{User.current.id} and watchable_id=#{self.id} and watchable_type='#{self.class}'").first
          if(nowatcher.nil?)
            self.set_watcher(self.current_journal.user, true)
          end
        end
      end

      def recipients_with_tipit_patch
        to_notify = recipients_without_tipit_patch
        watchers.each do | watcher |
          to_notify << watcher.user.mail
        end
        if to_notify.nil? 
          to_notify = []
        else
          to_notify.uniq!
        end
        to_notify
      end

      def set_start_date
        if (self.changes.include?('status_id'))

          should_set_start_date = false

          new_status = IssueStatus.find_by_name('New')
          if(self.changes['status_id'][0] == new_status.id)
            should_set_start_date =true
          end


          if(should_set_start_date)
            self.start_date = User.current.today
          end

        end

      end

    end
  end

end
