class MainController < ApplicationController

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
  
  
end
