class MainController < ApplicationController
  require 'json'
  include Util
  
  def get_logged_in_user
    if cookies[:echidna_cookie].nil? or cookies[:echidna_cookie].empty?
      render :text => 'not logged in' and return false
    end
    render :text => session[:user]
  end
  
  def login
    cookies[:echidna_cookie] = {:value => params[:email],
      :expires => 1000.days.from_now }
    session[:user] = params['email']
    render :text => params[:email]
  end
  
  def logout
    cookies.delete(:echidna_cookie)
    session[:user] = nil  
    render :text => 'logged out'
  end
  
  #cookies[:gwap2_cookie] = {:value => user.email,
  #  :expires => 1000.days.from_now }
  
  def get_all_conditions
    conds = Condition.find :all, :order => 'id'
    sorted_conds = sort_conditions_for_time_series(conds)
    headers['Content-type'] = 'text/plain'
    
    render :text => sorted_conds.to_json#.map{|i|i.name}.join("\n")
  end
  
  def check_if_group_exists
    group = ConditionGroup.find_by_name params[:group_name]
    render :text => (not group.nil?)
  end
  
  def create_new_group
    ids = JSON.parse params[:ids]
    group = ConditionGroup.new(:name => params[:name])
    group.save
    ids.each_with_index {|i,index|ConditionGrouping.new(:condition_id => i, :condition_group_id => group.id, :sequence => index +1).save}
    render :text => group.id
  end
  
  def get_all_groups
    groups = ConditionGroup.find :all, :order => 'name'
    ret = []
    groups.each do |g|
      h = g.attributes
      h['num_results'] = g.num_results
      ret << {"condition_group" => h}
    end
    render :text => ret.to_json # todo find out how to run the AR::B version of to_json
  end
    
end
