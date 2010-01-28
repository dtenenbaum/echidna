class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.column :name, :string
      t.column :alternate_name, :string
    end
  end

  def self.down
    drop_table :species
  end
end
