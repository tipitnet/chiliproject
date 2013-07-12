namespace :test do
	namespace :enhanced_mail do
		desc 'Run all unit tests for Enhanced Incoming Email Plugin'
		Rake::TestTask.new(:unit) do |t|
			t.test_files = FileList['vendor/plugins/chiliproject_enhanced_incoming_mail/test/unit/*_test.rb']
			t.verbose = true
		end
	end
end