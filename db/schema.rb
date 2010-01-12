# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100112230858) do

  create_table "condition_groupings", :force => true do |t|
    t.integer  "condition_id",       :limit => 11
    t.integer  "condition_group_id", :limit => 11
    t.integer  "sequence",           :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "condition_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conditions", :force => true do |t|
    t.integer  "experiment_id",        :limit => 11
    t.string   "name"
    t.integer  "sequence",             :limit => 11
    t.boolean  "has_data"
    t.integer  "forward_slide_number", :limit => 11
    t.integer  "reverse_slide_number", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original_name"
    t.integer  "sbeams_project_id",    :limit => 11
    t.string   "sbeams_timestamp"
  end

  add_index "conditions", ["id"], :name => "index_conditions_on_id"

  create_table "data_types", :force => true do |t|
    t.string "name"
  end

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

  create_table "genes", :force => true do |t|
    t.string "name"
    t.string "alias"
  end

  add_index "genes", ["id"], :name => "index_genes_on_id"

  create_table "relationship_types", :force => true do |t|
    t.string   "name"
    t.string   "inverse"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.integer "relationship_type_id", :limit => 11
    t.integer "group1",               :limit => 11
    t.integer "group2",               :limit => 11
    t.string  "note"
  end

end
