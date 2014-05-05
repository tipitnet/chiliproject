#!/usr/bin/env sh
bundle exec rake test:tipit_extensions:unit
rm -rf vendor/plugins/chiliproject_tipit_extensions # Remove this plugin because it modifies default behaviour and brake tests
bundle exec rake test:$TEST_SUITE