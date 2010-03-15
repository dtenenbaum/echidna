class CreateSubSearches < ActiveRecord::Migration
  def self.up
    create_table :sub_searches do |t|
      t.column :user_search_id, :integer
      t.column :environmental_perturbation, :string
      t.column :knockout, :string
      t.column :free_text_term, :string
      t.column :include_related, :boolean
      t.column :refine, :boolean
      t.column :last_results_option_selected, :string
      t.column :sequence, :integer
    end
  end

  def self.down
    drop_table :sub_searches
  end
end
