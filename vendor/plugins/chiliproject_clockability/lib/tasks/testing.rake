namespace :test do
  namespace :clockability do
    desc 'Run all unit tests for Clockability Plugin'
    Rake::TestTask.new(:unit) do |t|
      t.test_files = FileList['vendor/plugins/chiliproject_clockability/test/unit/*.rb']
      t.verbose = true
    end

    desc 'Run all functional tests for Clockability Plugin'
    Rake::TestTask.new(:functional) do |t|
      t.test_files = FileList['vendor/plugins/chiliproject_clockability/test/functional/*.rb']
      t.verbose = true
    end

  end
end