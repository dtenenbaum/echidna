class AddOriginalNameToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :original_name, :string
  end

  def self.down
  end
end
