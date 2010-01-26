class UserMailer < ActionMailer::Base
  

  def confirm_password(user, bodyhash)
    subject    'Echidna Password Confirmation'
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
