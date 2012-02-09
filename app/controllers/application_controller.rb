class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :has_extension?, :extension_available?
  
  #Access denied routing
  rescue_from CanCan::AccessDenied do |exception|
    if exception.subject.class.name == "Post"
      if user_signed_in?
        respond_to do |format|
          format.html {
            @sidebar = {:news => false, :posts => true}
            render "posts/noaccess"
          }
          format.markdown { render "posts/noaccess"  }
          format.iframe { render "posts/noaccess" }
          format.json { render :json => {:error => "no access"} }
        end
      else
        respond_to do |format|
          format.html {
            redirect_to new_user_session_path, :notice => 'You might have access to this if you login.'
          }
          format.markdown { render "login"  }
          format.iframe { render "login" }
          format.json { render "login" }
        end
      end
    else
      render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    end
  end
  
  protected
    Browser = Struct.new(:browser, :version)
    ExtensionBrowsers = [
      Browser.new("Firefox", "3.6.0.0"),
      Browser.new("Chrome", "1.0")
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
      if request.headers['Privly-Version']
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
end
