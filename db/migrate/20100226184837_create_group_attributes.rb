class CreateGroupAttributes < ActiveRecord::Migration
  def self.up
    create_table :group_attributes do |t|
      t.column :group_id, :integer
      t.column :key, :string
      t.column :string_value, :string
      t.column :int_value, :integer
      t.column :float_value, :float
    end
  end

  def self.down
    drop_table :group_attributes
  end
end
