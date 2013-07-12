# == Share Controller
#
# The share controller manages Shares, which grant permissions to posts.
# All permissioned share requests are redirected to their associated
# posts.
#
class SharesController < ApplicationController
  
  # Assigns the instance variables if the request has permission to them.
  load_and_authorize_resource
  
  # == Create a share.
  #
  # Requires share permission or ownership on the associated post.
  #
  # === Routing  
  #
  # Create a share
  # POST /shares
  # POST /shares.json
  #
  # === Formats  
  #  
  # * +html+
  # * +json+
  # * +jsonp+
  #
  # === Parameters
  #
  # <b>share [post_id]</b> - _integer_ - Required
  # * Values: 1 to 9999999
  # * Default: nil
  # Gives the post the share is permissioning. The user must own
  # the post or have share permission on an existing share.
  #
  # <b>share [identity_provider_name]</b> - _string_ - Optional
  # * Values: a string signifying a known identity type.
  # * Default: nil
  # Give a valid email, domain (preceded by the @ sign), or IPv4 address.
  # If the CSV is specified, then this parameter is ignored.
  #
  # <b>share [identity]</b> - _string_ - Optional
  # * Values: a string representing an identity with the identity_provider_name
  # * Default: nil
  # Give a valid email, domain (preceded by the @ sign), or IPv4 address.
  # If the CSV is specified, then share [identity] is ignored.
  #
  # <b>share [share_csv]</b> - _csv_ - Optional
  # * Values: a single row of comma separated values
  # * Default: nil
  # Send in comma separated values representing identities
  # like domains, emails, and IP Addresses. If the CSV is specified,
  # then share [identity] is ignored.
  # 
  # <b>share [can_show]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: true
  # Assign a show sharing permission to the identity or share_csv row's values
  #
  # <b>share [can_update]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a update sharing permission to the identity or share_csv row's values
  #
  # <b>share [can_destroy]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a destroy sharing permission to the identity or share_csv row's values
  #
  # <b>share [can_share]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a share sharing permission to the identity or share_csv row's values
  #
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
        format.html { 
          redirect_to post_path(@share.post,
            @share.post.url_parameters.merge(
              :content_password => params[:content_password])),
          :notice => "#{@shares.length} shares were successfully created." }
        format.json { render :json => {}, :status => :created }
      end
    else
      identity_provider = IdentityProvider.find_by_name(params[:share][:identity_provider_name])
      @share.identity_provider = identity_provider
      
      respond_to do |format|
        if @share.save
          format.html { redirect_to post_path(@share.post, 
                                    @share.post.url_parameters.merge(:content_password => params[:content_password])), 
                                    :notice => 'Share was successfully created.' }
          format.json { render :json => @share, :status => :created }
        else
          format.html { redirect_to post_path(@share.post, @share.post.url_parameters.merge(:content_password => params[:content_password])), 
                                    :alert => @share.errors.full_messages }
          format.json { render :json => @share.errors, 
                               :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # == Destroy a share.
  #
  # Requires share permission or ownership on the associated post.
  #
  # === Routing  
  #
  # DELETE /shares/:id
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters
  #
  # <b>share [id]</b> - _integer_ - Required
  # * Values: 1 to 9999999
  # * Default: nil
  # The ID of the share we are destroying.
  def destroy
    @post = @share.post
    @share.destroy
    redirect_to post_path(@post, @post.url_parameters.merge(:content_password => params[:content_password])), 
                                 :notice => 'Share was destroyed.'
  end
  
  # == Update a share.
  #
  # Requires share permission or ownership on the associated post.
  #
  # === Routing  
  #
  # Create a share
  # PUT /shares/:id
  # PUT /shares/:id.json
  #
  # === Formats  
  #  
  # * +html+
  # * +json+
  # * +jsonp+
  #
  # === Parameters
  #
  # <b>share [id]</b> - _integer_ - Required
  # * Values: 1 to 9999999
  # * Default: nil
  # The ID of the share we are updating.
  #
  # <b>share [post_id]</b> - _integer_ - Optional
  # * Values: 1 to 9999999
  # * Default: nil
  # Change which post the share is associated with. Most likely you do
  # not want to change this value. The user must own this post.
  #
  # <b>share [identity]</b> - string - Optional
  # * Values: a string representing an identity with the identity_provider_name
  # * Default: nil
  # Give a valid email, domain (preceded by the @ sign), or IPv4 address.
  # You cannot change identity types.
  # 
  # <b>share [can_show]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: nil
  # Assign a show sharing permission to the identity or share_csv row's values
  #
  # <b>share [can_update]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: nil
  # Assign a update sharing permission to the identity or share_csv row's values
  #
  # <b>share [can_destroy]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: nil
  # Assign a destroy sharing permission to the identity or share_csv row's values
  #
  # <b>share [can_share]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: nil
  # Assign a share sharing permission to the identity or share_csv row's values
  #
  def update
    respond_to do |format|
      if @share.update_attributes(params[:share])
        format.html { redirect_to post_path(@share.post, 
                        @share.post.url_parameters.merge(:content_password => params[:content_password])
                        ), 
                        :notice => 'Share was successfully updated.' }
        format.json { head :ok }
      else
        format.html { redirect_to post_path(@share.post, @share.post.url_parameters.merge(:content_password => params[:content_password])), :notice => 'We could not update that email share.' }
        format.json { render :json => @share.errors, :status => :unprocessable_entity }
      end
    end
  end

end
