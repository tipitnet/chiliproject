module Clockability
  class ViewWelcomeIndexHook < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context={ })

      error_message = context[:request].session[:clock_error]

      if (!error_message.nil?)
        return "<div style=\"color:red\">#{error_message}</div>"
      end

    end

    def view_welcome_index_left(context={ })
      if(User.current.anonymous?)
        return
      else
        if(User.current.groups.include?(Group.find_by_lastname('tipit-staff')))

          pending_sync_items = TimeEntry.all(:conditions => ["synced = ? AND user_id = ?", false, User.current.id])

          locals = {:pending_items => pending_sync_items, :error => nil}
          if (!context[:request].session[:clock_error].nil?)
            locals[:error] = context[:request].session[:clock_error]
          end
          context[:controller].send(:render_to_string, {
              :partial => "pending_sync_items",
              :locals => locals})
        end
      end
    end
  end
end