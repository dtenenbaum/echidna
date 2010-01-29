class ImportHumanFeatures
  unless ARGV.length == 1
    puts "supply a filename"
    exit
  end
  
  require 'pp'
  
  conds = Condition.find(:all, :conditions => "species_id = 2")
  cond_hash = {}
  for cond in conds
    cond_hash[cond.name] = cond.id
  end
  
  pos_to_cond = {}
  gene_name = "nothing"
  gene_id = -1
  
  file = File.open(ARGV.first)
  first = true

begin
  Feature.transaction do
    while(line = file.gets)
      line.chomp!
      if (first)
        cond_names = line.split("\t")
        cond_names.each_with_index do |cond_name, i|
          next if i == 0
          pos_to_cond[i] = cond_hash[cond_name]
        end
        first = false
        next
      end
      segs = line.split("\t")
      segs.each_with_index do |seg, i|
        if i == 0
           g = Gene.new(:name => seg)
           g.save
           gene_id = g.id
        else
          # are these ratios?
          f = Feature.new(:condition_id => pos_to_cond[i], :value => seg, :data_type => 1, :gene_id => gene_id)
          #pp f
          f.save
        end
      end
      
    end
  end
rescue Exception => ex
  puts ex.message
  puts ex.backtrace
end


  
end