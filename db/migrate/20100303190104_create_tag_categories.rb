class CreateTagCategories < ActiveRecord::Migration
  def self.up
    create_table :tag_categories do |t|
      t.string "category_name"
    end
  end

  def self.down
    drop_table :tag_categories
  end
end
