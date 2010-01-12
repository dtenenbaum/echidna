class AddSbeamsInfoToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :sbeams_project_id, :integer
    add_column :conditions, :sbeams_timestamp, :string
  end

  def self.down
    remove_column :conditions, :sbeams_project_id
    remove_column :conditions, :sbeams_timestamp
  end
end
