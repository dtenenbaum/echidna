class AddGeneNames
  f = File.open("#{RAILS_ROOT}/haloTigr.anno")
  first = true
  
  begin
    Condition.transaction do

      while (line = f.gets)
        if first
          first = false
          next
        end
        orf, gene_name, function = line.chomp.split("\t")
        gene = Gene.find_by_name(orf)
        if gene.nil? or gene_name =~ /^VNG/
          puts "skipping #{orf}"
        else
          gene.gene_name = gene_name
          puts "setting gene name to #{gene_name} for #{orf}"
          gene.save
        end
      end

    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
  
end