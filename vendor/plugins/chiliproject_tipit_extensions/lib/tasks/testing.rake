namespace :test do
  namespace :tipit_extensions do
    desc 'Run all unit tests for Tipit Extensions Plugin'
    Rake::TestTask.new(:unit) do |t|
      t.test_files = FileList['vendor/plugins/chiliproject_tipit_extensions/test/unit/*.rb']
      t.verbose = true
    end
  end
end