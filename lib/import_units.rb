class ImportUnits
  require 'pp'
  
  oldunits = Legacy.find_by_sql "select id, name from units where name is not null"
  newunits = Unit.find_by_sql "select id, name from units where name is not null"
  
  oldconds = Legacy.find_by_sql "select * from conditions"
  
  old_vocab = Legacy.find_by_sql "select id, name from controlled_vocab_items"
  new_vocab = ControlledVocabItem.find :all
  
  old_vocab_map = {}
  new_vocab_map = {}
  new_vocab_map_by_name = {}
  
  for item in old_vocab
    old_vocab_map[item.id] = item.name
  end
  
  for item in new_vocab
    new_vocab_map[item.id] = item.name
    new_vocab_map_by_name[item.name] = item.id
  end
  
  
  old_units_map = {}
  new_units_map = {}
  new_units_map_by_name = {}
  
  for item in oldunits
    old_units_map[item.id] = item.name
  end
  
  for item in newunits
    new_units_map[item.id] = item.name
    new_units_map_by_name[item.name] = item.id
  end
  
  
  puts "old_vocab_map:"
  pp old_vocab_map
  
  puts "new_vocab_map:"
  pp new_vocab_map
  
  puts "new_vocab_map_by_name:"
  pp new_vocab_map_by_name
  
  puts "old_units_map:"
  pp old_units_map
  
  puts "new_units_map:"
  pp new_units_map
  
  puts "new_units_map_by_name:"
  pp new_units_map_by_name
  
  #exit if true
  
  begin
    Condition.transaction do
      for oldcond in oldconds
        newcond = Condition.find_by_name(oldcond.name)
        oldobs = Legacy.find_by_sql(["select * from observations where condition_id = ?",oldcond.id])
        for oldob in oldobs
          next if oldob.units_id.nil? or oldob.units_id == 3
          #puts "old name_id = #{oldob.name_id}"
          key = old_vocab_map[oldob.name_id.to_i]
          #puts "key = #{key}"
          new_vocab_id = new_vocab_map_by_name[key]
          newob = Observation.find_by_sql(["select * from observations where condition_id = ? and  name_id = ?", newcond.id, new_vocab_id]).first
          
          next if newob.nil?
          
          ukey = old_units_map[oldob.units_id.to_i]
          new_unit = new_units_map_by_name[ukey]
          newob.units_id = new_unit

          puts "old: #{oldcond.name}\t#{key}\t#{ukey}"
          puts "new: #{newcond.name}\t#{newob.units_id}" #{new_vocab_map_by_name[new_vocab_id.to_i]}\t#{new_units_map_by_name[new_unit.to_i]}"
          puts
          
          
          newob.save
        end
        
      end
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
  
end