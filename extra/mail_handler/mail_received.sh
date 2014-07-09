#! /bin/sh

# This script is just for testing purposes. Before using it ensure that you have a project called initial-project-test and the api key matched the one below.

#localhost
cat "$1" | ruby ./rdm-mailhandler.rb --url http://localhost:3000 --unknown-user accept --project undefined-project --allow-override project,tracker,category,priority,status,sub-status --key klQnjKpT8K42HoOizfCv -v

#staging
#cat "$1" | ruby ./rdm-mailhandler.rb --url http://staging.chili.tipit.net --unknown-user accept --project undefined-project --allow-override project,tracker,category,priority,status --key JKzjWNBBZVV7b7qo2hH4 -v

# production
# cat "$1" | ruby ./rdm-mailhandler.rb --url https://chili.tipit.net --project undefined-project  --allow-override project,tracker,category,priority,status --key jnKXkcWEgTYtDZESXtIi -v
