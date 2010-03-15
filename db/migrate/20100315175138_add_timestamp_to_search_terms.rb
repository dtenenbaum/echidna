class AddTimestampToSearchTerms < ActiveRecord::Migration
  def self.up
    add_column :search_terms, :creation_time, :datetime
  end

  def self.down
    remove_column :search_terms, :creation_time
  end
end
