class ImportMoreExps
  require 'pp'
  
  def self.generate_condition_name()
    name = ''
    %W{s p d t}.each do |ltr|
    end
  end
  
  
  old_exps = Legacy.find_by_sql "select * from experiments where id != 430"

  begin
    Condition.transaction do
      old_exps.each do |old_exp|
        old_conds = Legacy.find_by_sql(["select * from conditions where experiment_id = ? order by sequence",old_exp.id])
        old_conds.each do |old_cond|
          old_obs = Legacy.find_by_sql(["select * from observations where condition_id = ?", old_cond.id])
          old_obs.each do |old_ob|
            pp old_ob.attributes
          end
        end
      end
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
end