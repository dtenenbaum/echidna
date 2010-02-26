class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.integer "paper_id",      :limit => 11
      t.integer "condition_id", :limit => 11
    end
  end

  def self.down
    drop_table :citations
  end
end
