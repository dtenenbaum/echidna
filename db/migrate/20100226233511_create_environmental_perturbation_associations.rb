class CreateEnvironmentalPerturbationAssociations < ActiveRecord::Migration
  def self.up
    create_table :environmental_perturbation_associations do |t|
      t.integer "environmental_perturbation_id", :limit => 11
      t.integer "condition_id",                 :limit => 11
    end
  end

  def self.down
    drop_table :environmental_perturbation_associations
  end
end
