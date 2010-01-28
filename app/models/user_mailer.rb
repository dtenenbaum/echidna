class UserMailer < ActionMailer::Base
  



  def password_refresh(user, bodyhash)
    subject    'Echidna Password Reset Link'
    @recipients = user.email
    hostname = `hostname`.chomp.downcase
    from       "echidna-noreply@#{hostname}"
    sent_on    Time.now
    
    body       bodyhash
  end
  

  def register(user, bodyhash)
    subject    'Echidna Registration Confirmation'
    @recipients = user.email
    hostname = `hostname`.chomp.downcase
    from       "echidna-noreply@#{hostname}"
    sent_on    Time.now
    
    body       bodyhash
  end

end
