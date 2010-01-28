class AddSpeciesFkToCondition < ActiveRecord::Migration
  def self.up
    add_column :conditions, :species_id, :integer
  end

  def self.down
    remove_column :conditions, :species_id
  end
end
