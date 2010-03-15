class AddIntTimestampToSearchTerms < ActiveRecord::Migration
  def self.up
    add_column :search_terms, :int_timestamp, :integer
  end

  def self.down
    remove_column :search_terms, :int_timestamp
  end
end
