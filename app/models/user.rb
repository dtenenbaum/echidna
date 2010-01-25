class User < ActiveRecord::Base
  validates_uniqueness_of :email
  
  delegate :name,  :to => :experiment, :prefix => :owner
#  delegate :email,  :to => :experiment, :prefix => :owner
  
  
  def self.authenticate(nick, pass)
    user = find(:first, :conditions => ['email = ?',nick])
    return false if user.nil?

    if Password::check(pass,user.password)
      user
    else
      return false
    end
  end

  protected

  # Hash the password before saving the record
  def update_password
    self.password = Password::update(self.password)
  end
  
  
  def before_save
    update_password
  end
  
end
