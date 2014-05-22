ActionController::Routing::Routes.draw do |map|
  map.connect 'sync', :controller => 'sync', :action => 'run'
end