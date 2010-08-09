class XmlGleaner
  require 'rexml/document'
  require 'pp'
  files = `ls -1 /Users/dtenenbaum/emi-sandbox/halobacterium/repos/*.xml`
  condmap = {}
  condnames = []
  names = {}
  for file in files.split("\n")
#    puts file
    xml = REXML::Document.new(File.open(file))
    root = xml.root
    consts = []
    xml.elements.each("//constants") do |i|
      i.elements.each("variable") do |v|
        name = v.attributes['name']
        names[name] = 1
        value = v.attributes['value']
        units = v.attributes['units']
        consts << [name, value, units]
      end
    end
    
    conds = []
    
    xml.elements.each("//condition") do |i|
      condname = i.attributes['alias']
      conds.push condname
      
      condmap[condname] = consts
      condnames.push condname
    end
    
    
    
  end
  
  condnames.sort!
  
  for cond in condnames
    puts "#{cond}\t"
    for item in condmap[cond]
      print "#{item.first}\t#{item[1]}"
      print "\t#{item.last}" unless item.last.nil?
      print "\n"
    end
    print "\n"
  end
  
  #pp condmap
end