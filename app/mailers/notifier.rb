# Send one-off emails
class Notifier < ActionMailer::Base
  default :from => "privly@privly.org",
           :return_path => "privly@privly.org"
  
  # Send a system update to the recipient (user account)
  def update(recipient)
    @user = recipient
    @user.last_emailed = Time.now
    @user.save
    mail(:to => recipient.email, :subject => "Protecting Privacy on the Internet: Priv.ly")
  end
end
