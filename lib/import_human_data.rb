class ImportHumanData
  unless ARGV.length == 1
    puts "supply a filename containing phenotype data"
    exit
  end
  
  f= File.open(ARGV.first)
  first = true
  
  name_to_id_map = {}
  id_to_name_map = {}
  position_to_id_map = {}
  
  begin
    Condition.transaction do
      while(line = f.gets)
        line.chomp!
        if first
          headers = line.split("\t")
          headers.each_with_index do |header, i|
            h = ControlledVocabItem.new(:name => header)
            h.save
            name_to_id_map[h.name] = h.id
            id_to_name_map[h.id] = h.name
            position_to_id_map[i] = h.id
          end
          first = false
          next
        end
        values = line.split("\t")
        next if values.first.empty?
        @cond_id = -1
        values.each_with_index do |value, i|
          value = "true" if value.downcase == "yes"
          value = "false" if value.downcase == "no"
          value = nil if value.downcase == "na"
          cond = Condition.new
          if i == 0
            cond.name = value
            cond.species_id = 2
            cond.has_data = true
            cond.save
            @cond_id = cond.id
            puts "initially, @cond_id = #{@cond_id}"
          else
            puts "now cond_id is #{@cond_id}"
            obs = Observation.new
            obs.condition_id = @cond_id
            obs.name_id = position_to_id_map[i]
            obs.string_value = value
            begin
              obs.int_value = Integer(value)
            rescue
            end
            begin
              obs.float_value = Float(value)
            rescue
            end
            obs.boolean_value  = true if value == "true"
            obs.boolean_value = false if value == "false"
            obs.is_measurement = false
            obs.is_time_measurement = false
            obs.save
          end
        end
      end
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
  
  
end