#!/usr/bin/env sh
set -e
bundle exec rake test:tipit_extensions:unit
bundle exec rake test:clockability:unit
bundle exec rake test:clockability:functional
rm -rf vendor/plugins/chiliproject_tipit_extensions # Remove this plugin because it modifies default behaviour and brake tests
rm -rf vendor/plugins/chiliproject_email_watchers # Remove this plugin because it modifies default behaviour and brake tests
rm -rf vendor/plugins/chiliproject_clockability # Remove this plugin because it modifies default behaviour and brake tests
bundle exec rake test:$TEST_SUITE