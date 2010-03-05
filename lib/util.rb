module Util
  require 'pp'

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
        #add_search_term("Condition", "name")
        add_search_term("Tag", "tag")
        # todo populate environmental_perturbations
        # todo - knockouts
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    "done"
  end

  private
  
  def add_search_term(table, fields)
    items = []
    line = "items = #{table}.find :all"
    eval(line)
    id_column = items.first.attributes.has_key?('condition_id') ? "condition_id" : "id"
    f_arr = (fields.is_a?(Array)) ? fields : [fields]
    for item in items
      for thing in f_arr
        s = SearchTerm.new(:condition_id => item.send(id_column), :word => item.send(thing))
        #pp s
        s.save
      end
    end
  end

end