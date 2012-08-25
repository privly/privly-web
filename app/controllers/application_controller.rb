class ApplicationController < ActionController::Base
  
  # Put the CSRF token into all forms, except where 
  # skip_before_filter :verify_authenticity_token
  # is specified
  protect_from_forgery
  
  helper_method :has_extension?, :extension_available?
  
  # Route the request to the proper "Access Denied" screen
  rescue_from CanCan::AccessDenied do |exception|
    
    @post = nil
    
    if exception.subject.class.name == "Post"
      if user_signed_in?
        respond_to do |format|
          format.html {
            @sidebar = {:posts => true}
            render "posts/noaccess"
          }
          format.iframe { render "posts/noaccess" }
          format.json { render :json => {:error => "no access"} }
        end
      else
        respond_to do |format|
          format.html {
            redirect_to new_user_session_path, :notice => 'You might have access to this if you login.'
          }
          format.iframe { render "login" }
          format.json {
            render :json => {:error => "you need to login"}, 
            :status => :unprocessable_entity 
          }
        end
      end
    else
      render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    end
  end
  
  protected
  
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
    
    # Structure for user agent inspection
    Browser = Struct.new(:browser, :version)
    ExtensionBrowsers = [
      Browser.new("Firefox", "4.0.0.0"),
      Browser.new("Chrome", "1.0"),
      Browser.new("Opera","11.0")
    ]
    ChromeBrowser = [
      Browser.new("Chrome", "1.0")
    ]
    def extension_available?
      user_agent = UserAgent.parse(request.user_agent)
      if ExtensionBrowsers.detect { |browser| user_agent >= browser }
        true
      else
        false
      end
    end
    
    def chrome_browser?
      user_agent = UserAgent.parse(request.user_agent)
      if ChromeBrowser.detect { |browser| user_agent >= browser }
        true
      else
        false
      end
    end
    
    def has_extension?
      if request.headers['X-Privly-Version']
        true
      else
        false
      end
    end
    
    def redirect_bot     
      if request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|fa|facebookexternalhit|facebookscraper)\b/i
        redirect_to root_url, :notice => "You have been flagged as a bot, if you are in fact human, please let us know so we will give you access."
      end
    end
    
  private

    #Give CanCan access to the random token
    #See: https://github.com/ryanb/cancan/wiki/Accessing-Request-Data
    def current_ability
      @current_ability ||= Ability.new(current_user, request.remote_ip, params[:random_token], params[:content_password])
    end
end
