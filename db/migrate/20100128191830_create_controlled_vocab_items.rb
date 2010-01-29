class CreateControlledVocabItems < ActiveRecord::Migration
  def self.up
    create_table :controlled_vocab_items do |t|
      t.string   "name"
      t.boolean  "approved"
      t.integer  "parent_id",  :limit => 11
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :controlled_vocab_items
  end
end
