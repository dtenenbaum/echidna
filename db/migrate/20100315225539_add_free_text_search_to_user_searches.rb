class AddFreeTextSearchToUserSearches < ActiveRecord::Migration
  def self.up
    add_column :user_searches, :free_text_search_terms, :string
  end

  def self.down
    remove_column :user_searches, :free_text_search_terms
  end
end
