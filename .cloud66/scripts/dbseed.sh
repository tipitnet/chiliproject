#!/bin/bash
cd $STACK_PATH
sudo touch /tmp/hook_start
bundle exec rake redmine:load_default_data
bundle exec rake generate_session_store
sudo touch /tmp/hook_end
