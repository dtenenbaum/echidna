class ConditionGroup < ActiveRecord::Base
  belongs_to :condition_groupings
  attr_accessor :ungrouped_ids
  
  def num_results
    ConditionGroup.find_by_sql(["select count(id) as result from condition_groupings where condition_group_id = ?",id]).first.result.to_i
  end
  
  def conditions
    Condition.find_by_sql(["select * from conditions where id in (select condition_id from condition_groupings where condition_group_id = ?) order by sequence",id])
  end
  
end
