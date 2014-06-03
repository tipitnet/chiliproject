#!/bin/bash
set -e

cd $STACK_PATH 
bundle exec rake generate_session_store
sudo chown -R nginx:app_writers files log tmp
sudo chmod -R 775 files log tmp
