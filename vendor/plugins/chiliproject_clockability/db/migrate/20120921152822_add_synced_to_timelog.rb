class AddSyncedToTimelog < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :synced, :boolean
  end

  def self.down
    remove_column :time_entries, :synced
  end
end
