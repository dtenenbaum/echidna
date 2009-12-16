class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table "features", :force => true do |t|
      t.integer "track_id",     :limit => 11
      t.float   "value"
      t.integer "data_type",    :limit => 11
      t.integer "gene_id",      :limit => 11
      t.integer "location_id",  :limit => 11
      t.integer "condition_id", :limit => 11
      t.integer "sequence_id",  :limit => 11
      t.integer "start",        :limit => 11
      t.integer "end",          :limit => 11
      t.boolean "strand"
    end

    add_index "features", ["gene_id"], :name => "index_features_on_gene_id"
    add_index "features", ["condition_id"], :name => "index_features_on_condition_id"
    add_index "features", ["data_type"], :name => "index_features_on_data_type"
  end

  def self.down
    drop_table :features
  end
end
