class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer "condition_id",    :limit => 11
      t.string  "tag"
      t.boolean "auto"
      t.boolean "is_alias"
      t.string  "alias_for"
      t.integer "tag_category_id", :limit => 11
    end
  end

  def self.down
    drop_table :tags
  end
end
