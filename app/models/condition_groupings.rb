class ConditionGroupings < ActiveRecord::Base
  has_many :conditions
  has_many :condition_groupings
end
