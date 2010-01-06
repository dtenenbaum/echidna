class AddMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :conditions, :id
    add_index :genes, :id
  end

  def self.down
    remove_index :conditions, :id
    remove_index :genes, :id
  end
end
