class AddGeneNameToGenes < ActiveRecord::Migration
  def self.up
    add_column :genes, :gene_name, :string
  end

  def self.down
    remove_column :genes, :gene_name
  end
end
