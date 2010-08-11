class EnvmapHelper
  
  require 'pp'
  
  def self.get_conditions_from_ids(cond_ids)       
    @envmap_file = ""
    @conditions = Condition.find_by_sql(["select * from conditions where id in (?)",cond_ids])
    @cond_exp_map = {}
    
    groupings = ConditionGrouping.find :all
    for group in groupings
      @cond_exp_map[group.condition_id] = group.condition_group_id # this is broken if a cond belongs to >1 group
    end
    
    
#    for cond in @conditions
#      @cond_exp_map[cond.id] = Experiment.find(cond.experiment_id)
#    end
    users = User.find :all
    @user_map = {}
    for user in users
      @user_map[user.id] = user
    end
    
    recipes = GrowthMediaRecipe.find :all
    @recipe_map = {}
    for recipe in recipes
      @recipe_map[recipe.id] = recipe
    end
    
  end

  def self.get_refmap()
    refs = ReferenceSample.find :all
    @ref_map = {}
    refs.each do |ref|
      @ref_map[ref.id.to_i] = ref.name
    end
    
  end

  def self.assemble_data()
    @all_prop_names = {}
    for condition in @conditions
      props = Observation.find :all, :conditions => ['condition_id = ?',condition.id]
      data = {}
      for prop in props
        prop.name = 'temperature' if prop.name == 'Temperature'
        if prop.name == 'knockout'
          ko = "KO_#{prop.string_value}"
          @all_prop_names[ko] = ' '
          data[ko] = "1"
        end
        @all_prop_names[prop.name] = ' '
        data[prop.name] = prop.string_value
      end                           
      condition['props'] = data
    end
  end             

  def self.print_header()
    @columns = @all_prop_names.keys.sort{|a,b| a.downcase <=> b.downcase}
    @envmap_file << "\t"
    line = ""
    for col in @columns
      line += col
      line += "\t"
    end           
    
    line += add_additional_headers()
    
    line.strip!
    line << "\n"
    @envmap_file << line
  end           


  def self.add_additional_headers()
    # add other info, to match add_additional_columns()
    # return tab-delimited string
    headers = "reference_sample\towner\timporter\tgrowth_media_recipe\ttemperature"
    return headers
  end

  def self.print_data()
    for condition in @conditions
      @envmap_file << condition.name
      @envmap_file << "\t"
      line = ""
      for col in @columns
        value = condition['props'][col]
        value = "NA" if value.nil? or value.strip.empty?
        line << value
        line << "\t"
      end
      
      line << add_additional_columns(condition)
      
      line.strip!
      line << "\n"
      @envmap_file << line
    end
  end

  def self.add_additional_columns(condition)
    # stuff to add:
    # reference sample (name?), importer email, owner email, temperature, growth media id (or name?)
    # return a tab-separated string containing the additional fields
    exp = @cond_exp_map[condition.id]
    ret = ""
    if (condition.reference_sample_id.nil?)
      ret += "NA"
    else
      #ret += @ref_map[exp.reference_sample_id.to_i]
      ret += condition.reference_sample_id
    end
    ret += "\t"
    
    ['owner_id','importer_id'].each do |meth|
      if (condition.send(meth).nil?)
        ret += "NA"
      else
        ret += @user_map[condition.send(meth).to_i].email
      end
      ret += "\t"
    end
    
    if (condition.growth_media_recipe_id.nil?)
      ret += "NA"
    else
      ret += @recipe_map[condition.growth_media_recipe_id.to_i].name
    end
    ret += "\t"
    
    #if (exp.temperature.nil?)
      ret += "NA"
    #else
    #  ret += "#{exp.temperature}"
    #end
    ret += "\t"
    #
    return ret
  end
        
  def self.get_envmap(condition_ids)
    get_conditions_from_ids(condition_ids)
    get_refmap()
    assemble_data()
    print_header() 
    print_data()     
    return @envmap_file
  end

#  main()
end