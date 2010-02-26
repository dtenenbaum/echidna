class AddOwnerIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :condition_groups, :owner_id, :integer
  end

  def self.down
    remove_column :condition_groups, :owner_id
  end
end
