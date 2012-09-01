class ApplicationController < ActionController::Base
  
  # Put the CSRF token into all forms, except where 
  # skip_before_filter :verify_authenticity_token
  # is specified
  protect_from_forgery
  
  before_filter :redirect_html_requests_to_root_domain if Privly::Application.config.redirect_html_requests_to_root_domain
  
  helper_method :has_extension?, :extension_available?, :firefox_browser?, 
                :opera_browser?, :chrome_browser?
  
  protected
    
    # Many links will be for domains other than the primary domain, 
    # but when users click the link they should be redirected back to
    # the primary domain. Multiple domains may be necessary to prevent
    # Privly links from being marked as spam. Only HTML format requests
    # should be directed here.
    def redirect_html_requests_to_root_domain
      
      if request.format == "html" and Privly::Application.config.primary_domain_host != request.host
        # Get all the request URL after the domain
        query_string_index = request.url.index("/", 8)
        if query_string_index
          redirect_to "#{request.protocol}#{Privly::Application.config.primary_domain_redirect}#{request.url[query_string_index, request.url.length]}"
        else
          redirect_to "#{Privly::Application.config.primary_domain}"
        end
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
    #I have no logic here because I have overloaded
    #the invitation logic to never send an invite on
    #first create. An admin must send the invite at
    #a later date.
    def authenticate_inviter!
    end
  
    #checks current user to see if they are administrators
    #and redirects them if they are not
    def require_admin
      unless user_signed_in? and current_user.admin?
        redirect_to root_url, :notice => "Only administrators have access to that."
      end
    end
    
    # Structures for user agent inspection
    Browser = Struct.new(:browser, :version)
    ExtensionBrowsers = [
      Browser.new("Firefox", "4.0.0.0"),
      Browser.new("Chrome", "1.0"),
      Browser.new("Opera","11.0")
    ]
    ChromeBrowser = [
      Browser.new("Chrome", "1.0")
    ]
    OperaBrowser = [
      Browser.new("Opera","11.0")
    ]
    FirefoxBrowser = [
      Browser.new("Firefox", "4.0.0.0")
    ]
    
    # Helper indicates whether the requestor has a browser
    # where an extension is available.
    def extension_available?
      user_agent = UserAgent.parse(request.user_agent)
      if ExtensionBrowsers.detect { |browser| user_agent >= browser }
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

    #Give CanCan access to the random token
    #See: https://github.com/ryanb/cancan/wiki/Accessing-Request-Data
    def current_ability
      @current_ability ||= Ability.new(current_user, request.remote_ip, params[:random_token], params[:content_password])
    end
end
