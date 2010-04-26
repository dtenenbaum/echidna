class PipelineImporter
  require 'pp'
  
  
  
  def self.get_oligo_map
    oligo_files = `ls -1 #{NET_ARRAYS}/Slide_Templates/halo_oligo*.map`

    tmp = []
    oligo_files.each do |i|
      num = i.split("_").last.gsub(/\.map$/,"")
      items = num.split("-")
      tmp << [items.first.to_i, items.last.to_i, i]
    end

    sorted = tmp.sort do |a,b|
      (a.first + a[1]) <=> (b.first + b[1])
    end                                           

    newest = sorted.last.last.chomp


    map = {}

    f = File.open(newest)
    first = true
    while (line = f.gets)     
      if first
        first = false
        next
      end
      segs = line.split("\t")
      ref = segs[4]
      vng = segs[10]
      map[ref] = vng
    end
    map
  end    
  
  def self.get_slide_numbers(project_id, timestamp) 
    ft_files = `ls -1 #{NET_ARRAYS}/Pipeline/output/project_id/#{project_id}/#{timestamp}/*.ft`.split("\n")
    map = {}
    for file in ft_files
      name = file.split("/").last().gsub(/\.ft$/,".sig")
      f = File.open(file)
      while (line = f.gets)         
        num = line.split(".").first
        forward_slide_number = num  if (line =~ /\tf\t1/)
        reverse_slide_number = num  if (line =~ /\tr\t2/)
      end
      map[name] = []
      map[name] << forward_slide_number
      map[name] << reverse_slide_number
    end
    map
  end
  
  def self.create_conditions(group, headers, slidenums)
    puts "creating conditions..."
    saved_conds = []
    conds = headers.split("\t")
    conds.pop
    conds.shift
    conds.shift
    conds = conds[0..(conds.size/2)-1]
    conds.each_with_index do |cond, i|
      c = Condition.new( :name => cond, :sequence => i+1,
        :forward_slide_number => slidenums[cond].first, :reverse_slide_number => slidenums[cond].last)
      c.save        
      cg = ConditionGrouping.new(:condition_group_id => group.id, :condition_id => :c.id, :sequence => i+1)
      cg.save
      #puts "saving condition:"
      #pp c
      saved_conds << c
    end
    saved_conds
  end

  def self.add_feature(value, index, conditions, type, gene_id)
    condition = conditions[index]
    datatype = 1 if (type == "ratios")
    datatype = 2 if (type == 'lambdas')
    ####f = Feature.new(:value => value, :condition_id => condition.id, :gene_id => gene_id, :data_type => datatype)
    
    @@textfile.puts("#{datatype}\t#{value}\t#{condition.id}\t#{gene_id}") unless index.nil?
    
    #####f.save
    #pp f
  end


  def self.add_features(line, conditions, oligo_map, genes)
    segs = line.split("\t")
    orig_name = segs.shift
    vng_name = oligo_map[orig_name]
    gene_id = genes.detect{|i|i.name == vng_name}.id #slow?
    #puts "mapping original name #{orig_name} to vng name #{vng_name} to gene_id #{gene_id}"
    segs.shift
    segs.pop
    mid = segs.length/2
    ratios = segs[0..(mid)-1]
    lambdas = segs[mid..segs.size]
    ratios.each_with_index {|value,i|add_feature(value,i, conditions, 'ratios', gene_id )}
    lambdas.each_with_index  {|value,i|add_feature(value,i, conditions, 'lambdas', gene_id )}
  end

  
  
  
  def self.import_experiment(project_id, timestamp, importer, test_mode=false)
    begin      
      oligo_map = get_oligo_map()     
      #puts "oligo map:"
      #pp oligo_map
      genes = Gene.find :all
      textfilename = "/tmp/echidna_#{Time.now.to_i}.txt"
      @@textfile = File.open(textfilename, "w")
      Condition.transaction do
        slidenums = get_slide_numbers(project_id, timestamp)
        #exp = Experiment.new(:sbeams_project_id => project_id.to_i, :sbeams_project_timestamp => timestamp,
        #  :platform_id => 1, :importer_id => importer.id, :species_id => 1, :curation_status_id => 1, :is_private => true, 
        #  :has_tracks => false)
        group = ConditionGroup.new(:name => "Conditions Imported #{Time.now} (TEST)", :owner_id => importer.id, :importer_id => importer.id)
        group.save
        f = File.open("#{NET_ARRAYS}/Pipeline/output/project_id/#{project_id}/#{timestamp}/matrix_output")
        count = -1
        while (line = f.gets)
          line.chomp! 
          next if line =~ /^NumSigGenes/
          next if line.strip.empty?
          count += 1
          next if count == 0
          conditions = create_conditions(group, line, slidenums) if count == 1
          next if count == 1
          add_features(line, conditions, oligo_map, genes)
        end
        @@textfile.close
        puts "bulk inserting features..."
        Condition.connection.execute("LOAD DATA INFILE '#{textfilename}'  INTO TABLE features FIELDS TERMINATED BY '\\t' LINES TERMINATED BY '\\n' (data_type, value, condition_id, gene_id)")
        File.delete(textfilename)
        puts "Created group #{group.id}." 
        return group
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    
  end 
  
  def self.delete_group(group_id)  
    # todo - delete all other associations
    g = ConditionGroup.find group_id
    begin
      Condition.transaction do
        for cond in g.conditions
          Feature.connection.execute("delete from features where condition_id = #{cond.id}")
          Observation.connection.execute("deletre from observations where condition_id = #{cond.id}")
          Condition.delete cond.id
        end
        ConditionGroup.delete(group_id)
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    
  end
  
  
end