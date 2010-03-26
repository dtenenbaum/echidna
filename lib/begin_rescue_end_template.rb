begin
  Condition.transaction do
  end
rescue Exception => ex
  puts ex.message
  puts ex.backtrace
end
