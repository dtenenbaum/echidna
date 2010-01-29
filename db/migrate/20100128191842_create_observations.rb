class CreateObservations < ActiveRecord::Migration
  def self.up
    create_table :observations do |t|
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
    end
  end

  def self.down
    drop_table :observations
  end
end
