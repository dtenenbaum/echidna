class CreateRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :relationship_types do |t|
      t.column :name, :string
      t.column :inverse, :string
      t.timestamps
    end
    RelationshipType.new(:name => 'control', :inverse => 'treated').save
  end

  def self.down
    drop_table :relationship_types
  end
end
