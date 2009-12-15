module Util
  
  
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
  
  


  

end