# Send one-off emails
class Notifier < ActionMailer::Base
  default :from => "no-reply@" + Privly::Application.config.link_domain_host,
          :return_path => "no-reply@" + Privly::Application.config.link_domain_host
  
  # Send a system update to the recipient (user account)
  def update_invited_user(recipient)
    @user = recipient
    @user.last_emailed = Time.now
    @user.save
    mail(:to => recipient.email, 
      :subject => "An update from " + Privly::Application.config.name)
  end
  
  # Send a "pending invitation" message to the user
  def pending_invitation(recipient)
    @user = recipient
    @user.last_emailed = Time.now
    @user.save
    mail(:to => recipient.email, 
      :subject => "Your Invitation to " + Privly::Application.config.name + " is pending")
  end
end
