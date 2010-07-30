module DataOutputHelper
    
    require 'pp'
    
    def get_matrix_data(cond_ids,data_type_str)
      data_types = DataType.find :all

      data_type = data_types.detect{|i|i.name.downcase =~ /#{data_type_str}/}.id
      
      tmp_table_name = "tmp_table_#{Time.now.to_i}"

    query = <<"EOF"
    select f.value, g.name as gene_name, c.name as condition_name from features f, genes g, conditions c, #{tmp_table_name} t
    where g.id = f.gene_id                                           
    and c.id = f.condition_id
    and f.condition_id = t.cid
    and f.data_type = ?
    order by g.name, t.id
EOF

      begin
        Condition.transaction do
          Condition.connection.execute("create table #{tmp_table_name} (id int not null auto_increment, cid int, primary key(id))")
          Condition.connection.execute("CREATE INDEX cid_index USING BTREE ON #{tmp_table_name} (cid)")
          Condition.connection.execute("CREATE INDEX id_index USING BTREE ON #{tmp_table_name} (id)")
          for cond_id in cond_ids
            Condition.connection.execute("insert into #{tmp_table_name} (cid) values (#{cond_id})")
          end
          data = Feature.find_by_sql([query,data_type])
          Condition.connection.execute("drop table #{tmp_table_name}")
          return data
        end
        
      rescue Exception => ex
      end

      #unsorted_data = Feature.find_by_sql([query,cond_ids,data_type])
      #sort_by_condition_group_sequence(Feature.find_by_sql([query,cond_ids,data_type]),cond_ids)
  end





      def get_matrix_data_small(cond_ids,data_type_str)
        puts "cond_ids = "
        pp cond_ids
        data_types = DataType.find :all

        data_type = data_types.detect{|i|i.name.downcase =~ /#{data_type_str}/}.id

        tmp_table_name = "tmp_table_#{Time.now.to_i}"

      query = <<"EOF"
      select f.value, f.gene_id, f.condition_id from features f, genes g, #{tmp_table_name} t
      where g.id = f.gene_id                                           
      and f.condition_id = t.cid
      and f.data_type = ?
      order by g.name, t.cid
EOF

        begin
          Condition.transaction do
            Condition.connection.execute("create table #{tmp_table_name} (cid int)")
            Condition.connection.execute("CREATE INDEX cid_index USING BTREE ON #{tmp_table_name} (cid)")
            for cond_id in cond_ids
              puts "in cond_id loop"
              Condition.connection.execute("insert into #{tmp_table_name} values (#{cond_id})")
            end
            data = Feature.find_by_sql([query,data_type])
            #Condition.connection.execute("drop table #{tmp_table_name}")
            puts "data size is #{data.length}"
            return data
          end

        rescue Exception => ex
        end
    end





  
  def get_matrix_data_for_group(group_id, data_type_str)
    data_types = DataType.find :all

    data_type = data_types.detect{|i|i.name.downcase =~ /#{data_type_str}/}.id

    cond_ids = Condition.find_by_sql(["select condition_id from condition_groupings where condition_group_id = ? order by sequence",
      group_id]).map{|i|i.condition_id}


    query = <<"EOF" # for now this query hardcodes some of the options above
    select f.*, g.name as gene_name, c.name as condition_name from features f, genes g, conditions c, condition_groupings gr
     where g.id = f.gene_id 
     and gr.condition_group_id = ?
     and gr.condition_id = c.id
     and c.id = f.condition_id
     and f.data_type = ?
     order by g.name, f.condition_id
EOF
    #unsorted_data = Feature.find_by_sql([query,cond_ids,data_type])
    sort_by_condition_group_sequence(Feature.find_by_sql([query,group_id,data_type]),cond_ids)
    
  end
  
  def get_alias_map
    genes = Gene.find :all
    alias_map = {}
    for gene in genes
      alias_map[gene.name] = gene.any_synonym unless gene.any_synonym.nil?
    end
    alias_map
  end
  
  
  def as_binary(data)
    puts "entering as_binary at #{Time.now}"
    values = data.map{|i|i.value}
    puts "data length = #{data.length}"
    puts "values length  = #{values.length}"
    data = nil
    packed = values.pack("G#{values.length}")
    puts "packed = \n#{packed}"
    puts "----"
    packed
  end
  
  def as_json(data)
    puts "entering as_json at #{Time.now}"
    alias_map = get_alias_map
    columns = data.map{|i|i.condition_name}.uniq
    col_ids = {}
    columns.each_with_index do |col, index|
      col_ids[col] = index
    end
    h = {}
    h['columns'] = columns
    rows = []
    cur_row = []
    
    #prev_gene_name = ""
    #data.each do |d|
    #  if d.gene_name == prev_gene_name
    #    #
    #  else
    #    rows << cur_row unless cur_row.empty?
    #    cur_row = []
    #  end
    #  cur_row << small_form_of(d,col_ids)
    #  prev_gene_name = d.gene_name
    #end
    
    
    data.inject("_nothing_") do |memo, i|
      
      
      unless i.gene_name == memo
        rows << cur_row unless cur_row.empty?
        cur_row = []
      end
      
      cur_row << small_form_of(i, col_ids, alias_map)
      
      i.gene_name
    end
    rows << cur_row 
    
    h['rows'] = rows
    puts "NUMBER OF ROWS!!!!!! #{rows.size}"
    ret = h.to_json
    puts "leaving as_json at #{Time.now}, sending #{ret.length} bytes"
    ret
  end

  def small_form_of(item, col_ids, alias_map)
    
    col_id = col_ids[item.condition_name]
    hsh = {'v' => item.value, 'g' => item.gene_name, 'c' => col_id}
    hsh['a'] = alias_map[item.gene_name] if alias_map.has_key?(item.gene_name)
    hsh
  end
  
  def sort_by_condition_group_sequence(data, cond_ids)
    pos = {}
    cond_ids.each_with_index do |cond_id, index|
      pos[cond_id.to_i] = index
    end
    #pp pos
    
    
    data.sort() do |a,b|
      if a.gene_name == b.gene_name
        pos[a.condition_id] <=> pos[b.condition_id]
      else
        a.gene_name <=> b.gene_name
      end
    end
  end
  
  
  def as_matrix(data) 
    out = "GENE\t"
    cond_list = []
    cond_hash = {}
    first_gene = data.first.gene_name
    count = 0
    data.each do |d|
      cond_list << d.condition_name unless cond_hash.has_key?(d.condition_name)
      cond_hash[d.condition_name] = 1
      count += 1 if d.gene_name == first_gene  # this won't work for location-based data
    end
    out += cond_list.join("\t")
    #out += "\n"
    rows_per_sample = data.size / count
    
    #puts "count = #{count}" 
    #puts "rows_per_sample = #{rows_per_sample}"
   
    line = ""
    count = 1
    
    output = []
    output.push(out)
    
    data.inject("_nothing_") do |memo, i|
      unless i.gene_name == memo
        line.gsub!(/\t$/,"")
        line << "\n"
        line << i.gene_name
        line << "\t"
        output.push(line)
        line = ""
      end
      line << "#{i.value}"
      line << "\t"
      if (count == data.size)
        output.push(line)
      end
      count += 1
      i.gene_name
    end
    output.join ""
  end  
  
  
end