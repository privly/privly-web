class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.json
  def index
    
    @authentications = current_user.authentications if current_user
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @authentications }
    end
  end

  # GET /authentications/1
  # GET /authentications/1.json
  def show
    
    if user_signed_in?
      @authentication = current_user.authentications.find(params[:id])
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @authentication }
    end
  end

  # GET /authentications/new
  # GET /authentications/new.json
  def new
    redirect_to new_authentication_path, :notice => "You can't manually create authentications."
  end

  # GET /authentications/1/edit
  def edit
    redirect_to authentications_new_path, :notice => "You can't edit authentications."
  end

  # POST /authentications
  # POST /authentications.json
  def create
    auth = request.env["omniauth.auth"]
    current_user.authentications.find_or_create_by_provider_and_uid(auth['provider'], auth['uid'])
    redirect_to authentications_url, :notice => "Authentication successful."
  end

  # PUT /authentications/1
  # PUT /authentications/1.json
  def update
    redirect_to authentications_new_path, :notice => "You can't update authentications."
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.json
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end
end
