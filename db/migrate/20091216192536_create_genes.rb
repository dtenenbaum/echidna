class CreateGenes < ActiveRecord::Migration
  def self.up
    create_table "genes", :force => true do |t|
      t.string "name"
      t.string "alias"
    end
  end

  def self.down
    drop_table :genes
  end
end
