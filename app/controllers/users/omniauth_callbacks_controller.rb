class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
  def facebook
    auth = request.env["omniauth.auth"]
    email = auth.extra.raw_info.email
    uid = auth.uid
    
    @user = User.find_for_oauth("facebook", uid, email)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
end