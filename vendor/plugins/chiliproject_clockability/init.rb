require 'redmine'

require 'dispatcher'
Dispatcher.to_prepare :chiliproject_clockability do

  require_dependency 'timelog_controller'
  unless TimelogController.included_modules.include? Clockability::TimelogControllerPatch
    TimelogController.send(:include, Clockability::TimelogControllerPatch)
  end

  require_dependency 'issues_controller'
  unless IssuesController.included_modules.include? Clockability::IssuesControllerPatch
    IssuesController.send(:include, Clockability::IssuesControllerPatch)
  end

  require_dependency 'project'
  unless Project.included_modules.include? Clockability::ProjectPatch
    Project.send(:include, Clockability::ProjectPatch)
  end

end

Redmine::Plugin.register :chiliproject_clockability do
  name 'Chiliproject Clockability plugin'
  author 'Nicolas Paez'
  description 'This plugin implements integration with Clockability.'
  version '1.0.0'
  url 'http://www.tipit.net/about'
end

require 'clockability/view_welcome_index_hook'
require 'clockability/hooks'