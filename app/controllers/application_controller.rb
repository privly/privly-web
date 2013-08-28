# The application controller defines a number of helpers and filters
# for other elements of the application.
class ApplicationController < ActionController::Base
  
  # Put the CSRF token into all forms, except where 
  # skip_before_filter :verify_authenticity_token
  # is specified
  protect_from_forgery
  
  helper_method :has_extension?, :extension_available?, :firefox_browser?, 
                :opera_browser?, :chrome_browser?
  
  protected
    
    # If the user is not signed in, all "access denied" and
    # "Not Found" requests will be 403 and prompt the user to
    # sign in. If the user is signed in, all "access denied" and
    # "Not Found" requests will be 403 and indicate that the
    # resource may or may not exist.
    def obscure_existence
      
      # Forbidden and not found should both be forbidden
      response.status = 403
      
      respond_to do |format|
        if user_signed_in?
          format.html {
            @sidebar = {:posts => true}
            render "posts/noaccess"
          }
          format.iframe { render "posts/noaccess" }
          format.json { render :json => {:error => "You do not have access or it doesn't exist."}}
        else
          format.html {
            redirect_to new_user_session_path, :notice => 'You might have access to this when you login, if it exists.'
          }
          format.iframe { render "login" }
          format.json {
            render :json => {:error => "No access or it does not exist. You might have access to this if you login."}, 
            :status => :unprocessable_entity}
        end
      end
    end
    
    #filter for devise_invitable
    #https://github.com/scambra/devise_invitable
    #I have no logic here because this invite only serves
    #to verify the identity of the user.
    def authenticate_inviter!
    end
  
    #checks current user to see if they are administrators
    #and redirects them if they are not
    def require_admin
      unless user_signed_in? and current_user.admin?
        redirect_to root_url, :notice => "Only administrators have access to that."
      end
    end
    
    # This is a structure for user agent inspection.
    # The UserAgent gem uses this to process the user
    # agent into a known browser.
    Browser = Struct.new(:browser, :version)
    
    # All the browsers currently covered by extensions
    ExtensionBrowsers = [
      Browser.new("Firefox", "4.0.0.0"),
      Browser.new("Chrome", "1.0"),
      Browser.new("Opera","11.0")
    ]
    
    # The Chrome Browser
    ChromeBrowser = [
      Browser.new("Chrome", "1.0")
    ]
    
    # The Opera Browser
    OperaBrowser = [
      Browser.new("Opera","11.0")
    ]
    
    # The Firefox Browser
    FirefoxBrowser = [
      Browser.new("Firefox", "4.0.0.0")
    ]
    
    # Helper indicates whether the requestor has a browser
    # where an extension is available.
    def extension_available?
      user_agent = UserAgent.parse(request.user_agent)
      if user_agent and ExtensionBrowsers.detect { |browser| user_agent >= browser }
        true
      else
        false
      end
    end
    
    # Helper indicates whether the user is on a recent version of Google Chrome
    def chrome_browser?
      user_agent = UserAgent.parse(request.user_agent)
      if ChromeBrowser.detect { |browser| user_agent >= browser }
        true
      else
        false
      end
    end
    
    # Helper indicates whether the user is on a recent version of Opera
    def opera_browser?
      user_agent = UserAgent.parse(request.user_agent)
      if OperaBrowser.detect { |browser| user_agent >= browser }
        true
      else
        false
      end
    end
    
    # Helper indicates whether the user is on a recent version of 
    # Mozilla Firefox
    def firefox_browser?
      user_agent = UserAgent.parse(request.user_agent)
      if FirefoxBrowser.detect { |browser| user_agent >= browser }
        true
      else
        false
      end
    end
    
    # Helper indicates whether the end user has the Privly extension installed
    def has_extension?
      if request.headers['X-Privly-Version']
        true
      else
        false
      end
    end
    
  private

    # Devise: Where to redirect users once they have logged in
    def after_sign_in_path_for(resource)
      if user_signed_in? and current_user.can_post
        new_post_path
      else
        pages_about_path
      end
    end

    #Give CanCan access to the IP address, random token, and content password
    #See: https://github.com/ryanb/cancan/wiki/Accessing-Request-Data
    def current_ability
      @current_ability ||= Ability.new(current_user, request.remote_ip, params[:random_token], params[:content_password])
    end
end
