class AddReferenceSampleIdToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :reference_sample_id, :integer
  end

  def self.down
    remove_column :conditions, :reference_sample_id
  end
end
