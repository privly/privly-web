# Allow authentication through AJAX requests.
# The standard Devise controller is called when the request is not made
# by AJAX. 
 
class SessionsController < Devise::SessionsController
  
  def create
    if request.xhr?
      resource = warden.authenticate!(
        :scope => Devise::Mapping.find_scope!(:user), 
        :recall => "#{controller_path}#failure")
      sign_in_and_redirect(resource_name, resource)
    else
      super
    end
  end
  
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    sign_in("user", resource)
    return render :json => {:success => true}
  end
  
  def failure
    if request.xhr?
      return render :json => {:success => false, :errors => ["Login failed."]}
    else
      super
    end
  end
end