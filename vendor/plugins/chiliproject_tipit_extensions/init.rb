require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :chiliproject_tipit_extensions do

  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Issue.included_modules.include? TipitExtensions::IssuePatch
    Issue.send(:include, TipitExtensions::IssuePatch)
  end

  require_dependency 'user'
  unless User.included_modules.include? TipitExtensions::UserPatch
    User.send(:include, TipitExtensions::UserPatch)
  end

  require_dependency 'project'
  unless Project.included_modules.include? TipitExtensions::ProjectPatch
    Project.send(:include, TipitExtensions::ProjectPatch)
  end

  require_dependency 'wiki_controller'
  unless WikiController.included_modules.include? TipitExtensions::WikiControllerPatch
    WikiController.send(:include, TipitExtensions::WikiControllerPatch)
  end

  require_dependency 'wiki_controller'
  unless WatchersController.included_modules.include? TipitExtensions::WatchersControllerPatch
    WatchersController.send(:include, TipitExtensions::WatchersControllerPatch)
  end

end

Redmine::Plugin.register :chiliproject_tipit_extensions do
  name 'Chiliproject Tipit Extensions plugin'
  author 'NicoPaez'
  description 'This plugin implements some specific features for Tipit'
  version '0.0.1'
  url 'http://www.tipit.net/about'
end

require 'tipit_extensions/hooks'
