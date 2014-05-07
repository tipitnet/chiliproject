cd $STACK_PATH
bundle exec rake redmine:load_default_data
bundle exec rake generate_session_store

