class AddGwap2IdToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :gwap2_id, :integer
  end

  def self.down
    remove_column :conditions, :gwap2_id
  end
end
