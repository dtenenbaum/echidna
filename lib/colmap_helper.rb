class ColmapHelper

  require 'pp'

  def self.get_conditions_from_ids(cond_ids)       
    @colmap_file = ""
    @conditions = Condition.find_by_sql(["select * from conditions where id in (?)",cond_ids])
  end



  def self.get_num_ts()
    tshash = {}
    for condition in @conditions
      tshash[condition.experiment_id]  = ' '  if(condition['is_time_series'])
    end
    @numTS = tshash.keys.length.to_s #this can't be the # of time series
  end        

  def self.sort_conditions()
    @conditions.sort! do |a,b|
      if (a.experiment_id == b.experiment_id)
        if (a.sequence == b.sequence)
          a.id <=> b.id
        else
          a.sequence <=> b.sequence
        end
      else
        a.experiment_id  <=> b.experiment_id
      end
    end
  end

  def self.add_properties  
    for condition in @conditions
      data = {}
      props = Observation.find :all, :conditions => ['condition_id = ?',condition.id] #{condition.id} and property_type in(1,2)") 
      condition['is_time_series'] = false
      for prop in props  
        #puts "WHOA!!!!!" if condition.name =~ /^o2_set1_/ and prop.name == 'time'
        condition['is_time_series']  = true if prop.name == 'time'
        data[prop.name] = prop.string_value
      end
      condition['props'] = data
    end
  end

  def self.print_header()
    @colmap_file << "\tisTs\tis1stLast\tprevCol\tdelta.t\ttime\tts.ind\tnumTS\n"
  end                


  def self.generate_output()  
    ts_ind = 0              

    prev_cond = nil
    @conditions.each_with_index do |condition, i|

      if (i < @conditions.size)
        next_cond = @conditions[i+1]
      else
        next_cond = nil
      end


      ts = false
      ts = true if (condition['is_time_series'] == true)


      firstInSeries = true if prev_cond.nil?
      firstInSeries = true if ((!prev_cond.nil?) and (prev_cond.experiment_id != condition.experiment_id))
      firstInSeries = false if ((!prev_cond.nil?) and (prev_cond.experiment_id == condition.experiment_id))

      lastInSeries = false
      lastInSeries = true if (next_cond.nil?)
      lastInSeries = true if ((!next_cond.nil?) and (next_cond.experiment_id != condition.experiment_id))


      prevCol = condition.name      
      if (ts)
        prevCol = prev_cond.name unless firstInSeries
      end

      middleOfSeries = false
      middleOfSeries = true if (!firstInSeries and !lastInSeries)

      is1stLast = "e"   
      is1stLast = "f" if firstInSeries and ts
      is1stLast = "m" if middleOfSeries and ts
      is1stLast = "l" if lastInSeries and ts    

      ts_ind += 1 if (firstInSeries and ts)


      @colmap_file << condition.name
      @colmap_file << "\t"
      isTs = (ts) ? "TRUE" : "FALSE"
      isTs.strip!
      @colmap_file << isTs
      @colmap_file << "\t"

      @colmap_file << is1stLast
      @colmap_file << "\t"


      @colmap_file << prevCol
      @colmap_file << "\t"

      delta_t = "9999"
      if (ts)
        if (middleOfSeries or lastInSeries)
          delta_t = condition['props']['time'].to_i - prev_cond['props']['time'].to_i
        end
      end  



      @colmap_file << delta_t.to_s
      @colmap_file << "\t"

      time = "NA"
      if (ts)
        time = condition['props']['time']
      end                                
      @colmap_file << time
      @colmap_file << "\t"

      ts_ind_value = "NA"
      if (ts)
        ts_ind_value = ts_ind
      end


      
      @colmap_file << ts_ind_value.to_s
      @colmap_file << "\t"       
      

      @colmap_file << @numTS
      @colmap_file << "\n"

      prev_cond = condition

    end 
    @colmap_file
  end

  
  def self.get_colmap(condition_ids)
   get_conditions_from_ids(condition_ids) 
   add_properties()  
   get_num_ts()
   sort_conditions()
   print_header()
   generate_output()
  end
end