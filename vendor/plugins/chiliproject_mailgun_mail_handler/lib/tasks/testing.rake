namespace :test do
  namespace :chiliproject_mailgun_mail_handler do

    desc 'Run all unit tests for chiliproject_mailgun_mail_handler Plugin'
    Rake::TestTask.new(:unit) do |t|
      t.test_files = FileList['vendor/plugins/chiliproject_mailgun_mail_handler/test/unit/*.rb']
      t.verbose = true
    end

  end
end