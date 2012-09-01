class PostsController < ApplicationController
  
  # Allow posting to the create_anonymous endpoint without the CSRF token
  skip_before_filter :verify_authenticity_token, :only => [:create_anonymous]
  
  # Force the user to authenticate using Devise
  before_filter :authenticate_user!, :only => [:destroy_all]
  
  # Checks request's permissions defined in ability.rb and loads 
  # resource if they have access. This will assign @post or @posts depending
  # on the action.
  load_and_authorize_resource :except => [:destroy_all, :create_anonymous, :get_csrf]
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    obscure_existence
  end
  
  # Obscure whether the record exists when denied access
  rescue_from CanCan::AccessDenied do |exception|
    
    # Count the number of requests the post has without being able to view it
    if not @post.nil? and not @post.user.nil?
      User.increment_counter(:nonpermissioned_requests_served, @post.user.id)
    end
    
    obscure_existence
  end
  
  # Gives logged in users a listing of their content.
  # GET /posts
  # GET /posts.json
  def index
    unless params[:format] == "csv"
      @posts = @posts.order('created_at DESC').page params[:page]
    end
    respond_to do |format|
      format.html {
        @sidebar = {:posts => true}
        render  # index.html.erb
      }
      format.json { render :json => @posts.to_json() }
      format.csv do |csv|
        @filename = "posts_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        csv_data = FasterCSV.generate("") do |csv|
          csv << ["content", "created_at", "updated_at", "public"]
          @posts.each do |post|
            csv << [post.content, post.created_at, post.updated_at, post.public]
          end
        end
        send_data csv_data, :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{@filename}"
      end
    end
  end
  
  # Shows an individual post. The iframe format is intended for injectable
  # applications.
  # GET /posts/1
  # GET /posts/1.json
  # GET /posts/1.iframe
  def show
    
    # If the post will be destroyed in the next cron job, tell the user
    # it is already gone.
    if not @post.burn_after_date.nil? and @post.burn_after_date < Time.now
      raise ActiveRecord::RecordNotFound
    end
    
    # Count the number of permissioned requests the post has.
    # Note that users could use this to indicate the number of times content
    # has been read. Do not expose this lightly.
    if not @post.user.nil?
      User.increment_counter(:permissioned_requests_served, @post.user.id)
    end
    
    @injectable_url = get_injectable_url
    response.headers["X-Privly-Url"] = @injectable_url
    #deprecated
    response.headers["privlyurl"] = @injectable_url
    
    @share = Share.new
    
    respond_to do |format|
      format.html {
        @sidebar = {:post => true, :posts => true}
        render
      }
      format.iframe { render }
      format.json {
        render :json => get_json, :callback => params[:callback]
      }
    end
  end
  
  # New post form.
  # GET /posts/new
  # GET /posts/new.json
  def new
    @sidebar = {:markdown => true, :posts => true}
    
    @post.burn_after_date = Time.now + 2.weeks
    
    respond_to do |format|
      format.html # new.html.erb
      format.json {
        render :json => get_json, :callback => params[:callback] 
      }
    end
  end
  
  # Present an editing form for an existing post.
  # GET /posts/1/edit
  def edit
    @sidebar = {:markdown => true, :post => true, :posts => true}
  end
  
  # Create a post
  # POST /posts
  #     Redirects to show
  # POST /posts.json
  def create
    
    if user_signed_in?
      @post.user = current_user
    end
    
    # Posts default to Private
    if params[:post][:public]
      @post.public = params[:post][:public]
    else
      @post.public = false
    end
    
    # The random token will be required for users other than the owner
    # to access the content. The model will generate a token before saving
    # if it is not assigned here.
    @post.random_token = params[:post][:random_token]
    
    # Set the length of time until the post is destroyed
    # by the server.
    if params[:post][:seconds_until_burn]
      seconds_until_burn = params[:post][:seconds_until_burn].to_i
      @post.burn_after_date = Time.now + seconds_until_burn.seconds
    elsif params[:post][:burn_after_date]
      @post.burn_after_date = params[:post][:burn_after_date]
    else
      @post.burn_after_date = Time.now + 14.days
    end
    
    respond_to do |format|
      if @post.save
        
        injectable_url = get_injectable_url
        response.headers["X-Privly-Url"] = injectable_url
        response.headers["privlyurl"] = injectable_url #deprecated
        
        format.html { redirect_to injectable_url, :notice => 'Post was successfully created.' }
        format.json { render :json => get_json, :status => :created, :location => @post }
        format.any { render :json => get_json, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
        format.any { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # Updates post
  # PUT /posts/1
  # PUT /posts/1.json
  def update
    
    # Permissions can only be updated by people with sharing permission
    unless can? :share, @post
      @post.public = params[:post][:public]
      @post.random_token = params[:post][:random_token]
    end
    
    # Attributes which may lead to the destruction of the content can only
    # be updated by people with destruction permissions
    if can? :destroy, @post
        if params[:post][:seconds_until_burn]
          seconds_until_burn = params[:post][:seconds_until_burn].to_i
          @post.burn_after_date = Time.now + seconds_until_burn.seconds
        elsif params[:post][:burn_after_date]
          @post.burn_after_date = params[:post][:burn_after_date]
        end
    end
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, :notice => 'Post was successfully updated.' }
        format.json { render :json => get_json, :callback => params[:callback] }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @post.errors,
          :status => :unprocessable_entity }
      end
    end
  end
  
  # Destroy the post
  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :ok }
    end
  end
  
  # A Create endpoint which will not associate the post with any user account
  # POST /posts/anonymous
  # POST /posts/anonymous.json
  def create_anonymous
    
    @post = Post.new(params[:post])
    
    if params[:post][:seconds_until_burn]
      seconds_until_burn = params[:post][:seconds_until_burn].to_i
      @post.burn_after_date = Time.now + seconds_until_burn.seconds
    else
      @post.burn_after_date = Time.now + 1.day
    end
    
    if @post.burn_after_date.nil? or @post.burn_after_date > Time.now + 1.day
      @post.burn_after_date = Time.now + 1.day
    end
    
    # Anonymous posts must be public
    @post.public = true
    
    respond_to do |format|
      if @post.save
        
        injectable_url = get_injectable_url
        response.headers["X-Privly-Url"] = injectable_url
        response.headers["privlyurl"] = injectable_url #deprecated
        
        format.html { redirect_to url, :notice => 'Post was successfully created.' }
        format.json {
          render :json => get_json, :status => :created, 
            :location => injectable_url, 
            :callback => params[:callback] }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, 
          :status => :unprocessable_entity }
      end
    end
  end
  
  # Destroys all the current user's posts
  # DELETE /posts/destroy_all
  def destroy_all
    posts = current_user.posts

    posts.each do |post|
      post.destroy
    end

    redirect_to posts_url, :notice => "Destroyed all Posts."
  end
  
  # Returns javascript with CSRF token
  # This should only be called by posting applications
  # before submitting forms.
  # GET /posts/get_csrf
  def get_csrf
    render :json => {:csrf => form_authenticity_token},
      :callback => params[:callback]
  end
  
  private
    
    # This helper gives the URL intendent for injection into the page
    def get_injectable_url
      if @post.burn_after_date
        sharing_url_parameters = {:random_token => @post.random_token, 
          :burntAfter => @post.burn_after_date.to_i, :privlyInject1 => true, 
          :host => Privly::Application.config.link_domain_host,
          :port => nil}
      else
        sharing_url_parameters = {:random_token => @post.random_token,
          :privlyInject1 => true, 
          :host => Privly::Application.config.link_domain_host,
          :port => nil}
      end
      url = post_url @post, sharing_url_parameters
      url
    end
    
    # This helper gives a JSON document containing only the 
    # attributes the requestor has access to
    def get_json
      
      if not @post.user.nil? and @post.user == current_user
        post_json = @post.as_json
      else
        post_json = @post.as_json(:except => [:user_id, :updated_at, 
           :created_at])
      end
      
      if not @post.content.nil?
        post_json.merge!(
        :rendered_markdown => @post.content.safe_markdown)
      end
      
      injectable_url = get_injectable_url
      post_json.merge!(
         :privlyurl => injectable_url, #Deprecated
         "X-Privly-Url" => injectable_url, :privlyInject1 => true)
      
      post_json
    end
  
end
