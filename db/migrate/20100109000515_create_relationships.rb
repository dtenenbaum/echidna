class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.column :relationship_type_id, :integer
      t.column :group1, :integer
      t.column :group2, :integer
      t.column :note, :string
    end
  end

  def self.down
    drop_table :relationships
  end
end
