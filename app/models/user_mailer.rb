class UserMailer < ActionMailer::Base
  

  def confirm_password(user)
    subject    'UserMailer#confirm_password'
    @recipients = user.email
    from       'echidna-noreply@bragi.systemsbiology.org'
    sent_on    Time.now
    
    body       :greeting => 'Hi,'
  end

  def register(user, sent_on = Time.now)
    subject    'UserMailer#register'
    @recipients = user.email
    from       'echidna-noreply@bragi.systemsbiology.org'
    sent_on    sent_on
    
    body       :greeting => 'Hi,'
  end

end
