class EmailSharesController < ApplicationController
  
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    @post = Post.find(params[:email_share][:post_id])
    @email_share = @post.email_shares.build(params[:email_share])
    respond_to do |format|
      if @email_share.save
        format.html { redirect_to @post, :notice => 'Email Share was successfully created.' }
        format.json { render :json => @email_share, :status => :created, :location => @email_share }
      else
        format.html { redirect_to @post, :alert => @email_share.errors.full_messages }
        format.json { render :json => @email_share.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = @email_share.post
    @email_share.destroy
    redirect_to @post, :notice => 'Email Share was destroyed.'
  end
  
  def update
    
    @post = @email_share.post
    
    respond_to do |format|
      if @email_share.update_attributes(params[:email_share])
        format.html { redirect_to @post, :notice => 'Email share was successfully updated.' }
        format.json { head :ok }
      else
        format.html { redirect_to @post, :notice => 'We could not update that email share.' }
        format.json { render :json => @email_share.errors, :status => :unprocessable_entity }
      end
    end
  end

end
