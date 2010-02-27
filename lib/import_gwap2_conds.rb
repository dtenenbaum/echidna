class ImportGwap2Conds
  require 'pp'
  
  existing_conds = Condition.find :all
  
  old_exps = Legacy.find_by_sql "select * from experiments where name not like '2009_Cu_Zn%'"

  old_cv = Legacy.find_by_sql "select id, name from controlled_vocab_items"
  old_cv_map = {}
  old_cv.each do |cv|
    old_cv_map[cv.id.to_i] = cv.name
  end
  
  #pp old_cv_map
  
  new_cv = ControlledVocabItem.find :all
  new_cv_map = {}
  new_cv.each do |cv|
    new_cv_map[cv.name] = cv.id
  end

  old_users = Legacy.find_by_sql "select * from users"
  old_user_map = {}
  old_users.each do |ou|
    old_user_map[ou.id.to_i] = ou.email
  end
  
  #pp old_user_map
  
  new_users = User.find :all
  new_user_map = {}
  new_users.each do |nu|
    new_user_map[nu.email] = nu.id
  end
  
  #pp new_user_map

  old_genes = Legacy.find_by_sql("select * from genes")
  old_gene_map = {}
  old_genes.each do |og|
    old_gene_map[og.id.to_i] = og.name
  end
  
  new_genes = Gene.find :all
  new_gene_map = {}
  new_genes.each do |ng|
    new_gene_map[ng.name] = ng.id
  end
  

  begin
    Condition.transaction do
      old_exps.each do |old_exp|
        old_citations = Legacy.find_by_sql "select distinct paper_id from citations where experiment_id = #{old_exp.id}"
        
        kos = Legacy.find_by_sql("select * from knockout_associations where experiment_id = #{old_exp.id}")
        
        eperts = Legacy.find_by_sql("select * from environmental_perturbation_associations where experiment_id = #{old_exp.id}")
        
        @owner = nil
        @importer = nil
        
        group = ConditionGroup.new(:name => old_exp.name, :is_time_series => false) 
        unless (old_exp.owner_id.nil?)
          email = old_user_map[old_exp.owner_id.to_i]
          group.owner_id = new_user_map[email]
          @owner = group.owner_id
        end

        unless (old_exp.importer_id.nil?)
          email = old_user_map[old_exp.importer_id.to_i]
          group.importer_id = new_user_map[email]
          @importer = group.importer_id
        end



        #todo set whether group is time series
        group.save
        #todo set group attributes with fields from old experiments table
        
        old_conds = Legacy.find_by_sql(["select * from conditions where experiment_id = ? order by sequence",old_exp.id])
        old_conds.each do |old_cond|
          hsh = old_cond.attributes
          hsh.delete('is_duplicate_of')
          cond = Condition.new(hsh)
          cond.gwap2_id = old_cond.id
          cond.reference_sample_id = old_exp.reference_sample_id
          cond.sbeams_project_id = old_exp.sbeams_project_id
          cond.sbeams_timestamp = old_exp.sbeams_project_timestamp
          cond.species_id = 1
          cond.owner_id = @owner #unless owner.empty?
          cond.importer_id = @importer #unless importer.empty?
          cond.growth_media_recipe_id = old_exp.growth_media_recipe_id
          #todo make sure this cond doesn't already exist in echidna
          cond.save
          #pp cond
          cg = ConditionGrouping.new(:condition_group_id => group.id, :condition_id => cond.id, :sequence => old_cond.sequence)
          cg.save
          #pp cg
          
          kos.each do |ko|
            a = KnockoutAssociation.new(:condition_id => cond.id, :knockout_id => ko.knockout_id)
            a.save
            #pp a
          end
          
          eperts.each do |epert|
            e = EnvironmentalPerturbationAssociation.new(:condition_id => cond.id, :environmental_perturbation_id => epert.environmental_perturbation_id)
            e.save
            #pp e
          end
          
          
          
          
          old_citations.each do |oc|
            c = Citation.new(:condition_id => cond.id, :paper_id => oc.paper_id)
            c.save
            #pp c
          end
          
          
          old_obs = Legacy.find_by_sql(["select * from observations where condition_id = ?", old_cond.id])
          old_obs.each do |old_ob|
            #pp old_ob.attributes
            name = old_cv_map[old_ob.name_id.to_i]
            
            #puts "name = #{name}, old id = #{old_ob.name_id}"
            
            
            if name == 'time'
              group.is_time_series = true
              group.save
              #puts "changed ts flag, group is:"
              #pp group
            end
            unless (new_cv_map.has_key?(name))
              ncv = ControlledVocabItem.new(:name => name)
              ncv.save
              #pp ncv
              new_cv_map[ncv.name] = ncv.id
            end
            
            ncv  = new_cv_map[name]
            
            new_ob = Observation.new(:condition_id => cond.id, :string_value => old_ob.string_value, :int_value => old_ob.int_value,
              :float_value => old_ob.float_value, :name_id => ncv)
            new_ob.save
            #pp new_ob
          end
          
          old_features = Legacy.find_by_sql "select * from features where condition_id = #{old_cond.id}"
          old_features.each do |of|
            nf = Feature.new(:value => of.value, :condition_id => cond.id, :data_type => of.data_type, :gene_id => of.gene_id)
            nf.save
          #  pp nf
          end
          
          # add:
          # reference_to
          # description
          #biological_replicate
          #is_control
          #is_controlled_by?
          
          
        end
      end
    end
    #raise "hell"
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
  
end