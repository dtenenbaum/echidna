class AddGrowthMediaRecipeToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :growth_media_recipe_id, :integer
  end

  def self.down
    remove_column :conditions, :growth_media_recipe_id
  end
end
