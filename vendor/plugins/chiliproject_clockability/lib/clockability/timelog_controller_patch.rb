require_dependency 'timelog_controller'

module Clockability

  module TimelogControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        alias_method_chain :create, :tipit_patch
      end

    end

    module ClassMethods

    end

    module InstanceMethods
      def create_with_tipit_patch(context={})
        result = create_without_tipit_patch

        time_entry = @time_entry
        if(time_entry.nil?)
          return
        end

        Rails.logger.debug("#{DateTime.now}>Hook>Processing time_entry #{time_entry.id}")

        origin = request.headers['HTTP_ORIGIN']
        return result if (!origin.nil? && origin.downcase.include?("clockability"))

        project = time_entry.project

        should_sync_with_clock = project.sync_with_clock

        return if should_sync_with_clock.nil?

        if((!time_entry.hours.nil?) && (should_sync_with_clock))
          
          user_key = time_entry.user.api_token.value

          data = Clockability::ClockabilityProxy.generate_json_message(time_entry)

          # Post data to Clock
          proxy = ClockabilityProxy.new
          response = proxy.send_data(data, user_key)
          result = (JSON.parse response)['Code']
          if(result == '100')
            time_entry.synced = true
            time_entry.save
            Rails.logger.info("#{DateTime.now}>Hook>time_entry: #{time_entry.id} processed. Response: #{response}")
          else
            error_message = "Synchronization failed. #{(JSON.parse response)['Message']}"
            raise RuntimeError, "Operation failed on project:#{project.name}. #{error_message}"
          end
        end

      rescue Exception => e
        if(!time_entry.nil?)
          time_entry.synced = false
          time_entry.save
          session[:clock_error] = "Synchronization failed. #{e.message}"
          Rails.logger.error("Hook> Error processing time_entry:#{time_entry.id}")
        end
        Rails.logger.error(e.message)
      end


    end
  end

end