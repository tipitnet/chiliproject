class AddSecondaryMailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :secondary_mail, :string
  end

end
