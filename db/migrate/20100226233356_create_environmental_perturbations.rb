class CreateEnvironmentalPerturbations < ActiveRecord::Migration
  def self.up
    create_table :environmental_perturbations do |t|
      t.string "perturbation"
    end
  end

  def self.down
    drop_table :environmental_perturbations
  end
end
