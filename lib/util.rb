module Util
  require 'pp'
  
  def valid_cookie?(cookie)
    email, hash = cookie.split(";")
    Password::check("#{email};#{SECRET_SALT}", hash)
  end
  
  def create_cookie(email)
    plaintext = "#{email};#{SECRET_SALT}"
    "#{email};#{Password::update(plaintext)}"
  end
  

  def find_related_groups(group_id)
    sql = "select r.*, t.name, t.inverse from relationships r, relationship_types t where t.id = r.relationship_type_id and  (r.group1 = ? or r.group2 = ?)"
    related_groups = Relationship.find_by_sql([sql, group_id, group_id])
    
    id_map= {}
    
    related_groups.each do |g|
      id_map[g.group1] = 1
      id_map[g.group2] = 1
    end
    
    
    names = ConditionGroup.find_by_sql(["select id, name from condition_groups where id in (?)", id_map.keys])
    names.each do |n|
      id_map[n.id] = n.name
    end

    #pp id_map

    
    related_groups.each do |g|
      g.relationship_id = g.id
      if (g.group1 == group_id) 
        g.id = g.group2
        g.relationship = g.inverse
        g.name = id_map[g.group2]
      else
        g.id = g.group1
        g.relationship = g.name
        g.name = id_map[g.group1]
      end
    end
    related_groups.sort! do |a,b|
      a.name <=> b.name
    end
    related_groups
  end
  
    def find_conditions_for_group(group_id)
      sql=<<"EOF"
      select c.id as id, c.name from conditions c, condition_groupings g
      where g.condition_id = c.id
      and g.condition_group_id = ?
      order by g.sequence
EOF
      conds = Condition.find_by_sql([sql, group_id])
    end
  
  
  def sort_conditions_for_time_series(conds)
    regex = /_t([+-][0-9]*)/
    conds.sort() do |a,b|
      #puts "a: #{a.name}, b: #{b.name}"
      if (a.name =~ regex and b.name =~ regex)
        a.name =~ regex
        a_num = $1
        b.name =~ regex
        b_num = $1
        
        a_temp = a.name.gsub(regex, "__PLACEHOLDER__")
        b_temp = b.name.gsub(regex, "__PLACEHOLDER__")
        
        if (a_temp == b_temp) # same time series
          a_pos =  b_pos = true
          
          #puts "a_num: #{a_num}, b_num: #{b_num}"
          a_pos = false if a_num =~ /^-/
          b_pos = false if b_num =~ /^-/

          [a_num,b_num].each {|i|i.gsub!(/^[+-]/,"")}
          [a_num,b_num].each {|i|i.gsub!(/^0/,"")}

          begin
            a = Integer(a_num)
            b = Integer(b_num)

            a = a - (a*2) unless a_pos

            b = b - (b*2) unless b_pos

            #puts "a = #{a}, b = #{b}"

            a <=> b

          rescue
            a.name <=> b.name
          end
          
        else
          #puts "not the same time series"
          a.name <=> b.name
        end
        
        
      else
        a.name <=> b.name
      end
    end
  end
  
  def update_search_terms
    begin
      Condition.transaction do
        Condition.connection.execute "truncate table search_terms"
        add_search_term("Condition", "name")
        add_group_names()
        add_controlled_vocab_items()
        add_environmental_perturbations()
        add_knockouts()
        add_search_term("Tag", "tag")
        # todo - knockouts
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    "done"
  end

  #############################
  # private functions
  #############################

  private
  
  def add_knockouts
    puts "add_knockouts"
    sql = "select k.gene as name, ka.condition_id from knockouts k, knockout_associations ka " +
      "where ka.knockout_id = k.id order by name, condition_id"
    add_items sql
  end
  
  def add_environmental_perturbations()
    puts "add_environmental_perturbations"
    sql = "select e.perturbation as name, a.condition_id from environmental_perturbations e, " +
      "environmental_perturbation_associations a where a.environmental_perturbation_id = e.id " + 
      "order by name, condition_id"
      add_items sql
  end
  
  def add_controlled_vocab_items()
    puts "add_controlled_vocab_items"
    sql = "select o.condition_id, n.name from observations o, controlled_vocab_items n " +
      "where o.name_id = n.id order by o.condition_id, n.name"
      add_items sql
  end
  
  def add_group_names()
    puts "add_group_names"
    sql = "select g.name, c.condition_id from condition_groups g, condition_groupings c " + 
      "where c.condition_group_id = g.id order by name, condition_id"
    add_items sql
  end
  
  def add_items(sql)
    items = Condition.find_by_sql(sql)
    #puts "# of items: #{items.size}, uniq size = #{items.uniq.size}"
    for item in items
      s = SearchTerm.new(:condition_id => item.condition_id, :word => item.name, :creation_time => Time.now, :int_timestamp => Time.now.to_i)
      s.save
    end
  end
  
  def get_groups_for_conditions(conds)
    groupings = ConditionGrouping.find :all
    groupmap = {}
    for grouping in groupings
      groupmap[grouping.condition_id] = [] unless groupmap.has_key?(grouping.condition_id)
      groupmap[grouping.condition_id] << grouping.condition_group_id
    end
#    puts "groupmap:"
#    pp groupmap
    group_ids_to_get = {}
    ungrouped_ids = []
    
    for cond in conds
      if (groupmap.has_key?(cond.id))
        groupmap[cond.id].each do |item|
          group_ids_to_get[item] = 1
        end
      else
        ungrouped_ids << cond.id
      end
    end
    puts "group_ids_to_get:"
    pp group_ids_to_get
    
    puts
    puts "ungrouped_ids:"
    pp ungrouped_ids
    
    groups = ConditionGroup.find_by_sql(["select * from condition_groups where id in (?) order by name", group_ids_to_get.keys])
    ungroup = ConditionGroup.new(:name => 'Ungrouped Results')
    ungroup.ungrouped_ids = ungrouped_ids
    groups << ungroup unless ungrouped_ids.empty?
    
    #groups.sort! do |a,b|
      
    #end
    
    groups
  end
  
  def add_search_term(table, fields)
    items = []
    line = "items = #{table}.find :all"
    eval(line)
    id_column = items.first.attributes.has_key?('condition_id') ? "condition_id" : "id"
    f_arr = (fields.is_a?(Array)) ? fields : [fields]
    for item in items
      for thing in f_arr
        s = SearchTerm.new(:condition_id => item.send(id_column), :word => item.send(thing), :creation_time => Time.now, :int_timestamp => Time.now.to_i)
        #pp s
        s.save
      end
    end
  end
  
  def group_description(group_id)
    group = ConditionGroup.find(params[:group_id])
    conds = Condition.find_by_sql(["select * from conditions where id in (select condition_id from condition_groupings where condition_group_id = ?) order by sequence",params[:group_id]])
    tags = Tag.find_by_sql(["select * from tags where condition_id in (#{conds.map{|i|i.id}.join(",")}) order by tag"])
    auto_tags = tags.find_all{|i|i.auto}.map{|i|i.tag}.uniq
    manual_tags = tags.reject{|i|i.auto}.map{|i|i.tag}.uniq
    ret = "Group Description:\n"
    ret += "Name: #{group.name}\n"
    ret += "Manual Tags: #{manual_tags.join(", ")}\n"
    ret += "Auto Tags: #{auto_tags.join(", ")}\n"
    ret += (group.is_time_series) ? "Time Series\n" : "Not Time Series\n"
    owner = (group.owner_id.nil?) ? nil : User.find(group.owner_id)
    importer =  (group.importer_id.nil?) ? nil : User.find(group.importer_id)
    ret += "Owner: #{(owner.nil?)  ? "unknown" : owner.email}\n"
    ret += "Conditions: #{conds.size}\n\n"
    for cond in conds
      ret += condition_description(cond.id)
    end
    ret
  end
  
  def condition_description(condition_id)
    cond = Condition.find(condition_id)
    species = Species.find(cond.species_id)
    ref = ReferenceSample.find(cond.reference_sample_id)
    recipe = GrowthMediaRecipe.find(cond.growth_media_recipe_id)
    obs = cond.observations
    ret = "Condition name: #{cond.name}\n"
    ret += "SBEAMS ID: #{cond.sbeams_project_id}\n"
    ret += "SBEAMS Timestamp: #{cond.sbeams_timestamp}\n"
    ret += "Forward Slide #: #{cond.forward_slide_number}\n" if cond.forward_slide_number
    ret += "Reverse Slide #: #{cond.reverse_slide_number}\n" if cond.reverse_slide_number
    ret += "Species: #{species.name}\n"
    ret += "Reference Sample: #{ref.name}\n"

    owner = (cond.owner_id.nil?) ? nil : User.find(cond.owner_id)
    importer =  (cond.importer_id.nil?) ? nil : User.find(cond.importer_id)
    ret += "Owner: #{(owner.nil?)  ? "unknown" : owner.email}\n"
    ret += "Imported By: #{(importer.nil?)  ? "unknown" : importer.email}\n"
    ret += "Recipe: #{recipe.name}\n"
    ret += "Observations:\n\n"
    for ob in obs
      ret += "#{ob.name} = #{ob.string_value}\n"
      
    end
    
    ret += "\n"
    ret
  end
  

end