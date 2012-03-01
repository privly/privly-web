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
    else
      @user = nil
    end
    respond_to do |format|
      format.html {
        if @user
          current_user.reset_authentication_token!
          redirect_to show_token_authentications_path
        else
          redirect_to new_token_authentication_path, :alert => "incorrect email or password"
        end
      }
      format.json { 
        if @user
          current_user.reset_authentication_token!
          redirect_to show_token_authentications_path({:format => :json})
        else
          render :json => {:error => "incorrect email or password"}, :callback => params[:callback] 
        end
      }
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
