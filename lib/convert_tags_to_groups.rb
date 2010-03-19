class ConvertTagsToGroups
  require 'pp'
  d_tags = Tag.find_by_sql(["select distinct tag, tag_category_id from tags"])
  tags_hash = {}
  tag_name_hash = {}


  
  d_tags.each do |i|
    tags_hash[[i.tag,i.tag_category_id]]  = 1
    tag_name_hash[i.tag] = 1
  end
  
#  pp tags_hash
#  exit if true

  eg = ConditionGroup.find_by_sql(["select distinct name from condition_groups"]).map{|i|i.name}
  existing_groups = {}
  eg.each do |item|
    existing_groups[item]  = 1
  end


  dupes = {}
  
  begin
    ConditionGroup.transaction do
      tags_hash.each_key do |k|
        if (existing_groups.has_key?(k.first))
          puts "WARNING! GROUP '#{k.first}' ALREADY EXISTS!!!"
          dupes[k.first] = 1
        else
          cg = ConditionGroup.new(:name => k.first, :type => k.last.to_i) # this doesn't work, "type" must be a reserved word or something?
          cg.type = k.last.to_i # this does work
          cg.save
          pp cg
          tags_hash[k] = cg.id
          tag_name_hash[k.first] = cg.id
        end
      end
      all_tags = Tag.find :all
      all_tags.each_with_index do |tag,i|
        if (dupes.has_key?(tag.tag))
          puts "SKIPPING ITEM '#{tag.tag}'"
        else
          cgi = ConditionGrouping.new(:condition_id => tag.condition_id, :condition_group_id => tag_name_hash[tag.tag]) #omit sequence
          cgi.save
          pp cgi
        end
      end
      raise :cain
    end
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace
  end
end