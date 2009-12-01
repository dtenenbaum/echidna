class ImportLeeDeepConds
  oldconds = Legacy.find_by_sql("select * from conditions where id in(select distinct condition_id from experiment_tags where tag = 'Lee/Deep 2009 Cu/Zn') order by id")
  require 'pp'
  
  begin
    Condition.transaction do
      for oldcond in oldconds
        #pp oldcond
        hsh = oldcond.attributes
        hsh.delete('is_duplicate_of')
        cond = Condition.new(hsh)
        #pp cond
        cond.save
      end 
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
end