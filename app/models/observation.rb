class Observation < ActiveRecord::Base
  belongs_to :condition
  belongs_to :controlled_vocab_item
end
