#!/bin/bash
set -e
cd $STACK_PATH
sudo touch /tmp/hook_start
bundle exec rake generate_session_store
bundle exec rake redmine:load_default_data
sudo touch /tmp/hook_end
