class AddWikiTemplateToProject < ActiveRecord::Migration

  def self.up
    add_column :projects, :wiki_template, :string
  end

end