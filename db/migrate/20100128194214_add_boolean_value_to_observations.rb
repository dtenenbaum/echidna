class AddBooleanValueToObservations < ActiveRecord::Migration
  def self.up
    add_column :observations, :boolean_value, :boolean
  end

  def self.down
    remove_column :observations, :boolean_value
  end
end
