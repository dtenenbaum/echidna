class Condition < ActiveRecord::Base
  belongs_to :condition_groupings
  belongs_to :species
  has_many :observations
  belongs_to :reference_sample
  belongs_to :growth_media_recipe
  
  belongs_to :importer, :class_name => "User"
  belongs_to :owner, :class_name => "User"
  
  attr_accessor :num_groups
  
  def num_groups_old
    Condition.find_by_sql(["select count(id) as result from condition_groupings where condition_id = ?",id]).first.result.to_i
  end
  
  def name_parseable?()  
    #sDura3_pZn_d0.005mM_t-015m
    segs = name.split("_")
    results = []
    %w{s p d}.each{|i|results << segs.detect{|j|j.downcase =~ /^#{i}/}}
    not results.include? nil
  end
  
  def self.populate_num_groups(conds)
    sql = "select condition_id, count(id) as result from condition_groupings where condition_id in (?) group by condition_id"
    results = Condition.find_by_sql([sql,conds.map{|i|i.id}])
    results_hash = {}
    results.each do |item|
      results_hash[item.condition_id.to_i] = item.result
    end
    conds.each do |cond|
      if results_hash.has_key?(cond.id.to_i)
        cond.num_groups = results_hash[cond.id.to_i]
      else
        cond.num_groups = 0
      end
    end
  end
  
  def parse_name
    #sDura3D1179_pCu_d0.700mM_t-015m_vs_NRC-1h1.sig
    res = {}
    segs = name.split("_")
    # todo -- what if it's not a time series?
    ['time','strain','perturbation','dosage'].each do |item|
      f = item[0,1]
      res[item] = segs.detect{|i|i =~ /^#{f}/}.gsub(/^#{f}/,"")
    end
    res
  end
  
  def get_obs
    raw = Observation.find_by_sql(["select c.name, o.string_value, o.name_id from observations o, controlled_vocab_items c where o.name_id = c.id and o.condition_id = ? order by name", self.id])
    res = {}
    for item in raw
      res[item.name] = item.string_value
    end
    res
  end 
  
end
