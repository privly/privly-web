class Notifier < ActionMailer::Base
  default :from => "privly@seanbmcgregor.com",
           :return_path => "privly@seanbmcgregor.com"
           
  def update(recipient)
    @user = recipient
    @user.last_emailed = Time.now
    @user.save
    mail(:to => recipient.email)
  end
end
