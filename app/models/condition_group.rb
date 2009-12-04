class ConditionGroup < ActiveRecord::Base
  belongs_to :condition_groupings
  
  def num_results
    ConditionGroup.find_by_sql(["select count(id) as result from condition_groupings where condition_group_id = ?",id]).first.result.to_i
  end
end
