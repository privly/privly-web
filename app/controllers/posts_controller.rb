class PostsController < ApplicationController
  
  # Allow posting to the create_anonymous endpoint without the CSRF token
  skip_before_filter :verify_authenticity_token, :only => [:create_anonymous]
  
  # Force the user to authenticate using Devise
  before_filter :authenticate_user!, :only => [:destroy_all]
  
  # Checks request's permissions defined in ability.rb and loads 
  # resource if they have access
  load_and_authorize_resource :except => [:destroy_all, :create_anonymous]
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    obscure_existence
  end
  
  # Obscure whether the record exists when denied access
  rescue_from CanCan::AccessDenied do |exception|
    
    if not @post.nil? and not @post.user.nil?
      # count the number of requests the post has without being able to view it
      User.increment_counter(:nonpermissioned_requests_served, @post.user.id)
    end
    
    obscure_existence
  end
  
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
        flash[:notice] = "Posts successfully exported" 
      end
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    
    if not @post.burn_after_date.nil? and @post.burn_after_date < Time.now
      raise ActiveRecord::RecordNotFound
    end
    
    # Count the number of permissioned requests the post has.
    # Note that users could use this to indicate the number of times content
    # has been read. Do not expose this lightly.
    if not @post.user.nil?
      User.increment_counter(:permissioned_requests_served, @post.user.id)
    end
    
    sharing_url_parameters = {:random_token => @post.random_token, 
      :privlyInject1 => true}
    
    if not @post.burn_after_date.nil?
      sharing_url_parameters[:random_token] = @post.random_token
    end
    
    #deprecated
    response.headers["privlyurl"] = post_url @post, sharing_url_parameters
    
    response.headers["X-Privly-Url"] = post_url @post, sharing_url_parameters
    
    @share = Share.new
    
    respond_to do |format|
      format.html {
        
        if request.url.include? "iframe"
          sharing_url_parameters[:format] = "iframe"
          url = post_url @post, sharing_url_parameters
          redirect_to url
          return
        end
        
        @sidebar = {:post => true, :posts => true}
        
        render
      }
      format.iframe { render }
      format.json {
        post_json = @post.as_json(:except => [:user_id, :updated_at, 
          :created_at])
        post_json.merge!(
          :rendered_markdown => @post.content.safe_markdown,
          :privlyurl => response.headers["privlyurl"], 
          "X-Privly-Url" => response.headers["X-Privly-Url"])
        render :json => post_json, :callback => params[:callback]
      }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @sidebar = {:markdown => true, :posts => true}
    
    @post.burn_after_date = Time.now + 2.weeks
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @sidebar = {:markdown => true, :post => true, :posts => true}
  end

  # POST /posts
  # POST /posts.json
  def create
    
    if user_signed_in?
      @post.user = current_user
    end
    
    unless params[:burn_after_date]
      if params[:post][:seconds_until_burn]
        seconds_until_burn = params[:post][:seconds_until_burn].to_i
        @post.burn_after_date = Time.now + seconds_until_burn.seconds
      end
    end
    
    respond_to do |format|
      if @post.save
        if @post.burn_after_date
          sharing_url_parameters = {:random_token => @post.random_token, 
            :burntAfter => @post.burn_after_date.to_i, :privlyInject1 => true}
        else
          sharing_url_parameters = {:random_token => @post.random_token, :privlyInject1 => true}
        end
        url = post_url @post, sharing_url_parameters
        
        #Deprecated
        response.headers["privlyurl"] = url
        
        response.headers["X-Privly-Url"] = url
        
        format.html { redirect_to url, :notice => 'Post was successfully created.' }
        format.json { render :json => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    
    unless can? :share, @post
      params[:post].delete :public
    end
    
    if can? :destroy, @post
        if params[:post][:seconds_until_burn]
          seconds_until_burn = params[:post][:seconds_until_burn].to_i
          @post.burn_after_date = Time.now + seconds_until_burn.seconds
        end
    else
      params[:post].delete burn_after_date
    end
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, :notice => 'Post was successfully updated.' }
        format.json { render :json => {:content => @post.content.safe_markdown}, :callback => params[:callback] }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

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
    
    @post.public = true
    
    respond_to do |format|
      if @post.save
        if @post.burn_after_date
          sharing_url_parameters = {:random_token => @post.random_token, 
            :burntAfter => @post.burn_after_date.to_i, :privlyInject1 => true}
        else
          sharing_url_parameters = {:random_token => @post.random_token, :privlyInject1 => true}
        end
        url = post_url @post, sharing_url_parameters
        
        #deprecated
        response.headers["privlyurl"] = url
        
        response.headers["X-Privly-Url"] = url
        
        format.html { redirect_to url, :notice => 'Post was successfully created.' }
        format.json { 
          post_json = @post.as_json
          post_json.merge!(:privlyurl => response.headers["X-Privly-Url"], :privlyInject1 => true)
          render :json => post_json, :status => :created, :location => @post, 
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
  
end
