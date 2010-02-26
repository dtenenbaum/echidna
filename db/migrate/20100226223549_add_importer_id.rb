class AddImporterId < ActiveRecord::Migration
  def self.up
    add_column :conditions, :importer_id, :integer
    add_column :condition_groups, :importer_id, :integer
  end

  def self.down
    remove_column :conditions, :importer_id
    remove_column :condition_groups, :importer_id
  end
end
