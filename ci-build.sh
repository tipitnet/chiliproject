#!/usr/bin/env sh
set -e
bundle exec rake test:tipit_extensions:unit
bundle exec rake test:enhanced_mail:unit

rm -rf vendor/plugins/chiliproject_tipit_extensions # Remove this plugin because it modifies default behaviour and brake tests
rm -rf vendor/plugins/chiliproject_email_watchers # Remove this plugin because it modifies default behaviour and brake tests
rm -rf vendor/plugins/chiliproject_enhanced_incoming_mail  # Remove this plugin because it modifies default behaviour and brake tests

bundle exec rake test:$TEST_SUITE