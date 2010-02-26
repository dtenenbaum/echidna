class CreateReferenceSamples < ActiveRecord::Migration
  def self.up
    create_table :reference_samples do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :reference_samples
  end
end
