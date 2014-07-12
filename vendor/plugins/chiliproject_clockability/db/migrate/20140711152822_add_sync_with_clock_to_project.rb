class AddSyncWithClockToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :sync_with_clock, :boolean
  end

  def self.down
    remove_column :projects, :sync_with_clock
  end
end
