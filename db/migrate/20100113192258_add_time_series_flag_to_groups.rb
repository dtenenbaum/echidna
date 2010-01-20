class AddTimeSeriesFlagToGroups < ActiveRecord::Migration
  def self.up
    add_column :condition_groups, :is_time_series, :boolean
  end

  def self.down
    remove_column :condition_groups, :is_time_series
  end
end
