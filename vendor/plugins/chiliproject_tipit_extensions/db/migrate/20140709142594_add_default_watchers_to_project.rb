class AddDefaultWatchersToProject < ActiveRecord::Migration

  def self.up
    add_column :projects, :default_watchers, :string
  end

end
