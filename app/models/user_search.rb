class UserSearch < ActiveRecord::Base
  has_many :sub_searches
end
