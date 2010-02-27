class CreateGrowthMediaRecipes < ActiveRecord::Migration
  def self.up
    create_table :growth_media_recipes do |t|
      t.string   "name"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "url"
    end
  end

  def self.down
    drop_table :growth_media_recipes
  end
end
