class AddUserIdAndSequenceToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :user_id, :integer
    add_column :tags, :sequence, :integer
  end

  def self.down
    remove_column :tags, :user_id
    remove_column :tags, :sequence
  end
end
