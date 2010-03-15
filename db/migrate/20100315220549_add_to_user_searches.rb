class AddToUserSearches < ActiveRecord::Migration
  def self.up
    add_column :user_searches, :name, :string
    add_column :user_searches, :is_structured, :boolean
  end

  def self.down
    remove_column :user_searches, :name
    remove_column :user_searches, :is_structured
  end
end
