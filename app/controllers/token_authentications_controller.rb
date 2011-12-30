class TokenAuthenticationsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:new, :create]
  
  def new
  end
  
  def show
    respond_to do |format|
      format.html {
        render
      }
      format.json { 
        render :json => {:auth_key => current_user.authentication_token }, 
          :callback => params[:callback] 
      }
    end
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if @user and @user.valid_password?(params[:password])
      sign_in(:user, @user)
      current_user.reset_authentication_token!
      redirect_to token_authentications_show_path
    else
      @user = nil
      redirect_to new_token_authentication_path, :alert => "incorrect email or password"
    end
    
  end

  def destroy
    current_user.authentication_token = nil
    current_user.save
    redirect_to new_user_session_path
  end

end
