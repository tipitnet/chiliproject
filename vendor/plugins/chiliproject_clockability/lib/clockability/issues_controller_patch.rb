require_dependency 'issues_controller'

module Clockability

  module IssuesControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        alias_method_chain :update, :tipit_patch
      end

    end

    module ClassMethods

    end

    module InstanceMethods
      def update_with_tipit_patch(context={})
        update_without_tipit_patch
        time_entry = @time_entry
        if(time_entry.nil?)
          return
        end
        project = time_entry.project

        Rails.logger.debug("Hook>Processing time_entry #{time_entry.id}")
        should_sync_with_clock = project.sync_with_clock

        return if should_sync_with_clock.nil?

        if((!time_entry.hours.nil?) && (should_sync_with_clock))

          user_key = time_entry.user.api_token.value

          data = Clockability::ClockabilityProxy.generate_json_message(time_entry)

          # Post data to Clock
          proxy = ClockabilityProxy.new
          response = proxy.send_data(data, user_key)
          result = (JSON.parse response)['Code']
          if(result == "100")
            time_entry.synced = true
            time_entry.save
            Rails.logger.info("Hook>time_entry: #{time_entry.id} processed. Response: #{response}")
          else
            error_message = "Synchronization failed. #{(JSON.parse response)['Message']}"
            raise RuntimeError, "Operation failed on project:#{project.name}. #{error_message}"
          end
        end

      rescue Exception => e
        time_entry.synced = false
        time_entry.save
        session[:clock_error] = "Synchronization failed. #{e.message}"
        Rails.logger.error("Hook> Error processing time_entry:#{time_entry.id}")
        Rails.logger.error(e.message)
      end

    end
  end

end