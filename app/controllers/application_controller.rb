# The application controller defines a number of helpers and filters
# for other elements of the application.
class ApplicationController < ActionController::Base
  
  # Put the CSRF token into all forms, except where 
  # skip_before_filter :verify_authenticity_token
  # is specified
  protect_from_forgery
  
  # Allow the user to authenticate using tokens
  # See: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  # or: http://stackoverflow.com/questions/18931952/devise-token-authenticatable-deprecated-what-is-the-alternative
  before_filter :authenticate_user_from_token!
  
  helper_method :has_extension?, :extension_available?, :firefox_browser?, 
                :opera_browser?, :chrome_browser?
  
  protected
    
    # Authenticate the user from a token. This is primarily used for mobile
    # applications. 
    def authenticate_user_from_token!
      auth_token = params[:auth_token].presence
      user       = auth_token && User.find_by_authentication_token(auth_token)

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if user && Devise.secure_compare(user.authentication_token, auth_token)
        # The user will not be logged in without the token
        sign_in user, store: false
      end
    end
    
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
          format.html { redirect_to "/apps/PlainPost/show.html" } # Deprecated
          format.json { render :json => 
            {:error => "You do not have access or it doesn't exist."}}
        else
          format.html {
            redirect_to new_user_session_path, 
              :notice => 'You might have access to this when you login, if it exists.'
          }
          format.json {
            render :json => 
            {:error => "No access or it does not exist. You might have access to this if you login."}, 
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
      if admin_user_signed_in?
        admin_root_path
      else
        "/apps/Help/new.html"
      end
    end

end
