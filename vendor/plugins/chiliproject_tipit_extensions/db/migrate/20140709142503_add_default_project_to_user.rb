class AddDefaultProjectToUser < ActiveRecord::Migration

  def self.up
    add_column :users, :default_project_id, :int
  end

end
