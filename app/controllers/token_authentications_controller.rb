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
    
    if @user and not @user.valid_password?(params[:password])
      @user.failed_attempts += 1
      if @user.failed_attempts >= Devise.maximum_attempts
        @user.lock_access!
      end
      @user.save
      @user = nil
    end
    
    if @user and @user.access_locked?
      @user = nil
    end
    
    if @user
      sign_in(:user, @user)
      respond_to do |format|
        format.html {
          current_user.reset_authentication_token!
          redirect_to show_token_authentications_path
        }
        format.json { 
          current_user.reset_authentication_token!
          redirect_to show_token_authentications_path({:format => :json})
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to new_token_authentication_path, :alert => "incorrect email or password"
        }
        format.json { 
          render :json => {:error => "incorrect email or password"}, :callback => params[:callback] 
        }
      end
    end
  end

  def destroy
    respond_to do |format|
      format.html {
        unless user_signed_in?
          redirect_to new_user_session_path, :error => "you are not signed in, we did not destroy a token"
        end
        current_user.authentication_token = nil
        current_user.save
        redirect_to new_token_authentication_path, :notice => "Your login token is no longer valid"
      }
      format.json { 
        unless user_signed_in?
          render :json => {:error => "You are not signed into Priv.ly", :callback => params[:callback]}
        end
        current_user.authentication_token = nil
        current_user.save
        render :json => {:message => "Your extension is now logged out of Priv.ly, but you are still logged into the website", :callback => params[:callback]}
      }
    end
  end
  
end
