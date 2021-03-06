#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

desc 'Load ChiliProject default configuration data. Language is chosen interactively or by setting CHILIPROJECT_LANG environment variable.'

namespace :redmine do
  task :load_default_data => :environment do
    include Redmine::I18n
    set_language_if_valid('en')

    envlang = ENV['CHILIPROJECT_LANG'] || ENV['REDMINE_LANG']
    if !envlang || !set_language_if_valid(envlang)
      while true
        print "Select language: "
        print valid_languages.collect(&:to_s).sort.join(", ")
        print " [#{current_language}] "
        STDOUT.flush
        lang = STDIN.gets.chomp!
        break if lang.empty?
        break if set_language_if_valid(lang)
        puts "Unknown language!"
      end
      STDOUT.flush
      puts "===================================="
    end

    Redmine::DefaultData::Loader.load(current_language)
    puts "Default configuration data loaded."

  end
end
