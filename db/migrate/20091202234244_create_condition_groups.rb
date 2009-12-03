class CreateConditionGroups < ActiveRecord::Migration
  def self.up
    create_table :condition_groups do |t|
      t.column :name, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :condition_groups
  end
end
