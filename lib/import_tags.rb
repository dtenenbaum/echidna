class ImportTags
  require 'pp'
  old_conds = Legacy.find_by_sql "select id, name from conditions"
  new_conds = Condition.find_by_sql "select id, name from conditions"
  
  old_cond_map = {}
  new_cond_map = {}
  
  for item in old_conds
    old_cond_map[item.id] = item.name
  end
  
  for item in new_conds
    new_cond_map[item.name] = item.id
  end
  
  tags = Legacy.find_by_sql "select tag, auto, is_alias, alias_for, tag_category_id, condition_id from experiment_tags"
  
  
  
  begin
    Condition.transaction do
      for tag in tags
        name = old_cond_map[tag.condition_id.to_i]
        tag.condition_id = new_cond_map[name]
        t = Tag.new(tag.attributes)
        t.save
#        pp t
      end
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
end