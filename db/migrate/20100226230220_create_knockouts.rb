class CreateKnockouts < ActiveRecord::Migration
  def self.up
    create_table :knockouts do |t|
      t.string   "gene"
      t.integer  "ranking",     :limit => 11
      t.string   "control_for"
      t.integer  "parent_id",   :limit => 11
    end
  end

  def self.down
    drop_table :knockouts
  end
end
