class SharesController < ApplicationController
  
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    
    identity_provider = IdentityProvider.find_by_name(params[:share][:identity_provider_name])
    @share.identity_provider = identity_provider
    
    respond_to do |format|
      if @share.save
        format.html { redirect_to @share.post, :notice => 'Share was successfully created.' }
        format.json { render :json => @share, :status => :created, :location => @share }
      else
        format.html { redirect_to @share.post, :alert => @share.errors.full_messages }
        format.json { render :json => @share.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = @share.post
    @share.destroy
    redirect_to @post, :notice => 'Share was destroyed.'
  end
  
  def update
    respond_to do |format|
      if @share.update_attributes(params[:share])
        format.html { redirect_to @share.post, :notice => 'Share was successfully updated.' }
        format.json { head :ok }
      else
        format.html { redirect_to @share.post, :notice => 'We could not update that email share.' }
        format.json { render :json => @share.errors, :status => :unprocessable_entity }
      end
    end
  end

end
