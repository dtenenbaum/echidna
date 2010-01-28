class User < ActiveRecord::Base
  validates_uniqueness_of :email
  
  delegate :name,  :to => :experiment, :prefix => :owner
#  delegate :email,  :to => :experiment, :prefix => :owner
  
  
  def self.authenticate(nick, pass, validate=true)
    user = find(:first, :conditions => ['email = ?',nick])
    return false if user.nil?
    if (validate)
      return false if user.validated == false or user.validated.nil?
    end

    if Password::check(pass,user.password)
      user
    else
      return false
    end
  end

  protected

  # Hash the password before saving the record
  def update_password
    #puts "ID ===== #{self.id}"
    existing = User.find(self.id)
    if (existing.password.nil? or (self.password.length < 192 and existing.password.length == 192))
      self.password = Password::update(self.password)
    end
  end
  
  
  def before_save
    update_password
  end
  
end
