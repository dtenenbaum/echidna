class ImportFeatures
  require 'pp'
  conds = Condition.find :all
  
  
  
  
  begin
    Feature.transaction do
#      Feature.connection.execute "truncate table genes"
#      Feature.connection.execute "truncable table features"
      
      old_genes = Legacy.find_by_sql("select * from genes order by id")
      for old_gene in old_genes
        hsh = old_gene.attributes
        gene = Gene.new(hsh)
        pp gene
        gene.save
      end
      
      
      for cond in conds
        oldcond = Legacy.find_by_sql(["select * from conditions where name= ?",cond.name]).first
        features = Legacy.find_by_sql(["select * from features where condition_id = ?", oldcond.id])
        for feature in features
          hsh = feature.attributes
          hsh.delete("id")
          hsh["condition_id"] = cond.id
#          pp hsh
          new_feature  = Feature.new(hsh)
          new_feature.save
        end
      end
      
    end
    puts "ok"
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
end