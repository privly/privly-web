class SharesController < ApplicationController
  
  load_and_authorize_resource
  
  # Create a single share, or a list of shares.
  # POST /posts
  #     Redirects to post show
  # POST /posts.json
  def create
    
    # If the CSV parameter is defined, then create a list of shares with
    # the same settings. Otherwise, create a single share from a known
    # share type.
    if not params[:share][:share_csv].nil? and 
      params[:share][:share_csv] != ""
      
      @shares = @share.post.add_shares_from_csv params[:share][:share_csv], 
                                                params[:share][:can_show], 
                                                params[:share][:can_update], 
                                                params[:share][:can_destroy], 
                                                params[:share][:can_share]
      respond_to do |format|
        format.html { redirect_to @share.post, :notice => "#{@shares.length} shares were successfully created." }
        format.json { render :json => {}, :status => :created }
      end
    else
      identity_provider = IdentityProvider.find_by_name(params[:share][:identity_provider_name])
      @share.identity_provider = identity_provider
      
      respond_to do |format|
        if @share.save
          format.html { redirect_to post_path(@share.post, :random_token => @share.post.random_token), :notice => 'Share was successfully created.' }
          format.json { render :json => @share, :status => :created }
        else
          format.html { redirect_to @share.post, :alert => @share.errors.full_messages }
          format.json { render :json => @share.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # Destroy the share
  # DELETE /shares/1
  # DELETE /shares/1.json
  def destroy
    @post = @share.post
    @share.destroy
    redirect_to post_path(@post, :random_token => @post.random_token), :notice => 'Share was destroyed.'
  end
  
  # Update the post
  # PUT /shares/1
  # PUT /shares/1.json
  def update
    respond_to do |format|
      if @share.update_attributes(params[:share])
        format.html { redirect_to post_path(@share.post, :random_token => @share.post.random_token), :notice => 'Share was successfully updated.' }
        format.json { head :ok }
      else
        format.html { redirect_to post_path(@share.post, :random_token => @share.post.random_token), :notice => 'We could not update that email share.' }
        format.json { render :json => @share.errors, :status => :unprocessable_entity }
      end
    end
  end

end
