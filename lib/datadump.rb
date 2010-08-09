class Datadump
  
  flatconds = Condition.find :all
  
  condmap = {}
  
  for item in flatconds
    condmap[item.id.to_i] = item.name
  end
  
  f = File.open("#{RAILS_ROOT}/db/matrixdata/ratios.txt", "w")
  
  
  
  
  query = <<"EOF"
  select gene_id, condition_id, value from features where data_type = ? limit ?, ?
EOF

chunk_size = 200000
current_position = 0
data_type = 1

pat = Regexp.compile(/\.CEL$/)
  
  while (true)
    puts current_position
    chunk = Feature.find_by_sql([query, data_type, current_position, chunk_size])
    break if chunk.empty? or chunk.nil?
    current_position += chunk_size
    for item in chunk
    #  puts "lala: #{condmap[item.condition_id.to_i]}"
      
      if condmap[item.condition_id.to_i] =~ pat
        #puts "cel!"
        next
      end
      f.puts "#{item.gene_id}\t#{item.condition_id}\t#{item.value}"
    end
  end
  
end