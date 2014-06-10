#!/bin/bash
set -e

cd $STACK_PATH 
bundle exec rake generate_session_store
sudo rm -R files
sudo ln -s /mnt/chiliproject1volume/tipitfiles/ files
sudo chown -R nginx:app_writers files log tmp
sudo chmod -R 775 files log tmp
