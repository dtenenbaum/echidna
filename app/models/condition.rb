class Condition < ActiveRecord::Base
  belongs_to :condition_groupings
  
  def num_groups
    Condition.find_by_sql(["select count(id) as result from condition_groupings where condition_id = ?",id]).first.result.to_i
  end
  
  def name_parseable?()  
    #sDura3_pZn_d0.005mM_t-015m
    segs = name.split("_")
    results = []
    %w{s p d}.each{|i|results << segs.detect{|j|j.downcase =~ /^#{i}/}}
    not results.include? nil
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
  
  
  
end
