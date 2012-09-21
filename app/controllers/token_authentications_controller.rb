# == TokenAuthenticationsController
#
# Manages token authentications for API access. Token authentications
# are currently only used by the Firefox Extension for logging in 
# directly from the extension. Token authentications are managed by
# the devise gem.
#
class TokenAuthenticationsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:new, :create]
  
  # == Get the Example TokenAuthentications Form
  # 
  # This page presents two forms for generating token authentications.
  # This endpoint should only be used to debug token authentications when
  # adding the functionality to a new endpoint.
  #  
  # ==== Routing  
  #
  # +GET+: /token_authentications/new
  #
  # ==== Formats  
  #  
  # * +html+
  #
  # ==== Parameters  
  # 
  # none
  #
  def new
  end
  
  # == Get the User's current Token.
  # 
  # The returned token when sent with future requests will associate the request
  # with the current user.
  #  
  # ==== Routing  
  #
  # +GET+: /token_authentications
  # +GET+: /token_authentications.:format
  #
  # ==== Cookies
  #
  # User must be authenticated via a session cookie
  #
  # ==== Formats  
  #  
  # * +html+
  # * +JSON+
  # * +JSONP+
  #
  # ==== Parameters  
  # 
  # none
  #
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
  
  # == Create a new Token Authentication.
  # 
  # The returned token when sent with future requests will associate the request
  # with the current user.
  #  
  # ==== Routing  
  #
  # +POST+: /token_authentications
  # +POST+: /token_authentications.:format
  #
  # ==== Formats  
  #  
  # * +html+
  # * +JSON+
  # * +JSONP+
  #
  # ==== Parameters  
  # 
  # * *email* - _string_ - Required
  # ** Values: Any valid email currently found in the user database
  # ** Default: nil
  #
  # * *password* - _string_ - Required
  # ** Values: The password associated with the email address
  # ** Default: nil
  #
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

  # == Destroy a Token.
  #
  # Destroy and invalidate all the user's token authentications
  #
  # === Routing  
  #
  # Destroy a post
  # DELETE /token_authentications
  # DELETE /token_authentications.:format
  #
  # ==== Cookies
  #
  # User must be authenticated via a session cookie
  #
  # === Formats  
  #  
  # * +html+
  # * +json+
  # * +jsonp+
  #
  # === Parameters  
  #
  # none
  #
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
