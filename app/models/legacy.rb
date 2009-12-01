class Legacy < ActiveRecord::Base
  establish_connection :legacy
  set_table_name "conditions"
end