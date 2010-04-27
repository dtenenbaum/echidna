class DeleteBogusFeatures
  min_id = 1998
  
  while(true)
    row = Feature.find_all_by_condition_id(min_id)
    puts "#{min_id} nil = #{row.nil?}"
    min_id += 1
    next if row.nil?
    for feature in row
      Feature.connection.execute("lock tables features write")
      Feature.connection.execute("delete from features where id = #{feature.id}")
    end
    #Feature.connection.execute("delete from features where id = #{row.id}")
    #Feature.delete(row)
    
  end
  
end