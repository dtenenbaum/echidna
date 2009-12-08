class Condition < ActiveRecord::Base
  belongs_to :condition_groupings
  
  def num_groups
    Condition.find_by_sql(["select count(id) as result from condition_groupings where condition_id = ?",id]).first.result.to_i
  end
end
