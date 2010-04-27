class CopyUnits
  oldunits = Legacy.find_by_sql("select * from units")
  require 'pp'
  
  for oldunit in oldunits
    u = Unit.new(oldunit.attributes)
    u.save
  end
end