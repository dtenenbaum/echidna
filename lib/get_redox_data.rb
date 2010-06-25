
include DataOutputHelper

class GetRedoxData

#  require "#{RAILS_ROOT}/lib/data_output_helper.rb"


  require 'pp'
  f = File.open("#{RAILS_ROOT}/wanted_conds_redox.txt")
  names = []
  while (line = f.gets)
    names << line.chomp
  end
#  pp names
#  data = as_matrix("goo")


#  conds = Condition.find_by_sql(["select * from conditions where name in (?)",names])
  conds = []
  for name in names
    c = Condition.find_by_name name
    conds << c
    #conds << Condition.find_by_name name
  end
  
  cond_names = conds.map{|i|i.name}

  cond_ids = conds.map{|i|i.id}
  
  #pp cond_names
  data = get_matrix_data(cond_ids,"lam")

  
  puts as_matrix(data)
  

end