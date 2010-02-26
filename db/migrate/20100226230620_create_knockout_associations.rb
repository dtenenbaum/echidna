class CreateKnockoutAssociations < ActiveRecord::Migration
  def self.up
    create_table :knockout_associations do |t|
      t.integer "knockout_id",   :limit => 11
      t.integer "condition_id", :limit => 11
    end
  end

  def self.down
    drop_table :knockout_associations
  end
end
