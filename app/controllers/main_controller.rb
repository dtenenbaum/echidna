class MainController < ApplicationController
  
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
  
  
end
