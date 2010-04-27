class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
        t.column :parent_id, :integer
        t.column :name, :string
        t.column :approved, :boolean # or should it be integer to match curation levels?
      t.timestamps
    end
  end

  def self.down
    drop_table :units
  end
end
