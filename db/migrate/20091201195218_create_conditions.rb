class CreateConditions < ActiveRecord::Migration
  def self.up
    create_table :conditions do |t|
      t.column :experiment_id, :integer
      t.column :name, :string
      t.column :sequence, :integer
      t.column :has_data, :boolean
      t.column :forward_slide_number, :integer
      t.column :reverse_slide_number, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :conditions
  end
end
