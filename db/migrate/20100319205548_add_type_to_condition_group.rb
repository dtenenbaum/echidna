class AddTypeToConditionGroup < ActiveRecord::Migration
  def self.up
    add_column :condition_groups, :type, :integer
  end

  def self.down
    remove_column :condition_groups, :type
  end
end
