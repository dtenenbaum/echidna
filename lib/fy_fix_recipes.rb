class FyFixRecipes
  f = File.open("/Users/dtenenbaum/Downloads/zzz_fyl_1.tsv")
  
  first = true
  
  
  
  begin
    Condition.transaction do
      while(line = f.gets)
        if first
          first = false
          next
        end
        condname, ref, recipe = line.chomp.split("\t")
        condname.gsub!(/^X/,"")
        condname.gsub!(/NRC\.1/,"NRC-1")
        cond = Condition.find_by_name(condname)
        if (cond.nil?)
          puts "MISSING CONDITION (#{condname})"
          next
        end
        gmr = -1
        gmr = 1 if recipe == 'CM'
        gmr = 4 if recipe == 'CDM'
        cond.growth_media_recipe_id = gmr
        cond.save
        puts "updated #{condname}..."
      end
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
end