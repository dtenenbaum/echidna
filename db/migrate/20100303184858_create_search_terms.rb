class CreateSearchTerms < ActiveRecord::Migration
  def self.up
    create_table :search_terms do |t|
      t.string   "word"
      t.integer  "group_id", :limit => 11
      t.integer  "condition_id",  :limit => 11
    end
  end

  def self.down
    drop_table :search_terms
  end
end
