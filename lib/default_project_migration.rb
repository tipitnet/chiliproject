class DefaultProjectMigration

  def self.run
    User.all.each do |user|
      default_project_name = user.custom_value_for(CustomField.find_by_name('Default Project'))
      puts "default_project_name: #{default_project_name}"
      if (default_project_name.nil? || default_project_name.to_s.empty?)
        next
      else
        project = Project.find_by_identifier(default_project_name.to_s)
        user.default_project_id = project.id
        user.save
      end
    end
  end

end