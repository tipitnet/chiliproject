module Clockability
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_projects_form,
              :partial => 'projects/extended_form_for_clock'

  end
end