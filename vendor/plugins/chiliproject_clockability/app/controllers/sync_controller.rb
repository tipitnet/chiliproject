class SyncController < ApplicationController
  include Clockability

  def run
    pending_sync_items = TimeEntry.all(:conditions => ["synced = ? AND user_id = ?", false, User.current.id])
    pending_sync_items.each do | time_entry |

      data = Clockability::ClockabilityProxy.generate_json_message(time_entry)
      user_key = time_entry.user.api_token.value

      # Post data to Clock
      proxy = Clockability::ClockabilityProxy.new
      response = proxy.send_data(data, user_key)
      result = (JSON.parse response)['Code']
      if(result == "100")
        time_entry.synced = true;
        time_entry.save
        Rails.logger.info("Hook>time_entry: #{time_entry.id} processed. Response: #{response}")
        session[:clock_error] = nil
        flash[:notice] = "Successful operation"
      else
        raise RuntimeError, (JSON.parse response)['Message']
      end
    end
  rescue Exception => e
    Rails.logger.error(e.message)
    flash[:error] = "Failed operation. #{e.message}"
    session[:clock_error] = "Failed operation. #{e.message}"
  ensure
    redirect_to :controller => 'Welcome'
  end
end