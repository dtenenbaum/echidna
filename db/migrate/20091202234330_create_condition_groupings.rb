class CreateConditionGroupings < ActiveRecord::Migration
  def self.up
    create_table :condition_groupings do |t|
      t.column :condition_id, :integer
      t.column :condition_group_id, :integer
      t.column :sequence, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :condition_groupings
  end
end
