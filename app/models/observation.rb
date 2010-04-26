class Observation < ActiveRecord::Base
  belongs_to :condition
  belongs_to :controlled_vocab_item
  
  def name
    ControlledVocabItem.find(name_id).name
  end
  
  def units
    #ack!
  end
end
