class CreateDataTypes < ActiveRecord::Migration
  def self.up
    create_table :data_types do |t|
      t.column :name, :string
    end                      
    DataType.new(:name => 'log10 ratios').save
    DataType.new(:name => 'lambdas').save
    DataType.new(:name => 'error').save
    
  end

  def self.down
    drop_table :data_types
  end
end
