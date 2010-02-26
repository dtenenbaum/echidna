class AddOwnerIdToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :owner_id, :integer
  end

  def self.down
    remove_column :conditions, :owner_id
  end
end
