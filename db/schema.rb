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

ActiveRecord::Schema.define(:version => 20100226230620) do

  create_table "citations", :force => true do |t|
    t.integer "paper_id",     :limit => 11
    t.integer "condition_id", :limit => 11
  end

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
    t.boolean  "is_time_series"
    t.integer  "owner_id",       :limit => 11
    t.integer  "importer_id",    :limit => 11
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
    t.integer  "species_id",           :limit => 11
    t.integer  "gwap2_id",             :limit => 11
    t.integer  "reference_sample_id",  :limit => 11
    t.integer  "owner_id",             :limit => 11
    t.integer  "importer_id",          :limit => 11
  end

  add_index "conditions", ["id"], :name => "index_conditions_on_id"

  create_table "controlled_vocab_items", :force => true do |t|
    t.string   "name"
    t.boolean  "approved"
    t.integer  "parent_id",  :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "group_attributes", :force => true do |t|
    t.integer "group_id",     :limit => 11
    t.string  "key"
    t.string  "string_value"
    t.integer "int_value",    :limit => 11
    t.float   "float_value"
  end

  create_table "knockout_associations", :force => true do |t|
    t.integer "knockout_id",  :limit => 11
    t.integer "condition_id", :limit => 11
  end

  create_table "knockouts", :force => true do |t|
    t.string  "gene"
    t.integer "ranking",     :limit => 11
    t.string  "control_for"
    t.integer "parent_id",   :limit => 11
  end

  create_table "observations", :force => true do |t|
    t.integer  "condition_id",        :limit => 11
    t.integer  "name_id",             :limit => 11
    t.string   "string_value"
    t.integer  "int_value",           :limit => 11
    t.float    "float_value"
    t.integer  "units_id",            :limit => 11
    t.boolean  "is_measurement"
    t.boolean  "is_time_measurement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "boolean_value"
  end

  create_table "papers", :force => true do |t|
    t.string "title"
    t.string "url"
    t.string "authors"
    t.text   "abstract"
    t.string "short_name"
  end

  create_table "reference_samples", :force => true do |t|
    t.string "name"
  end

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

  create_table "species", :force => true do |t|
    t.string "name"
    t.string "alternate_name"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.date     "last_login_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "validated"
    t.string   "first_name"
    t.string   "last_name"
  end

end
