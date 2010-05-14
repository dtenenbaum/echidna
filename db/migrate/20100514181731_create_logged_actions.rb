class CreateLoggedActions < ActiveRecord::Migration
  def self.up
    create_table :logged_actions do |t|
      t.column :user_id, :integer
      t.column :action, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :logged_actions
  end
end
