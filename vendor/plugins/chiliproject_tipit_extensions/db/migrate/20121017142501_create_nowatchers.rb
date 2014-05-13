class CreateNowatchers < ActiveRecord::Migration
  def self.up
    create_table :nowatchers do |t|
      t.column :user_id, :int
      t.column :watchable_id, :int
      t.column :watchable_type, :string
    end
  end

  def self.down
    drop_table :nowatchers
  end
end
