class PostsController < ApplicationController
  
  # Allow posting to the create_anonymous endpoint without the CSRF token
  skip_before_filter :verify_authenticity_token, :only => [:create_anonymous]
  
  # Force the user to authenticate using Devise
  before_filter :authenticate_user!, :except => [:show, :new, :create_anonymous]
  
  # Checks request's permissions defined in ability.rb and loads 
  # resource if they have access
  load_and_authorize_resource :except => [:destroy_all, :create_anonymous]
  
  # Use special logic for verifying that the user is human
  before_filter :authenticate_user_show!, :only => [:show]
  before_filter :redirect_bot, :only => :show
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    
    @post = nil
    
    if user_signed_in?
      respond_to do |format|
        format.html {
          @sidebar = {:news => false, :posts => true}
          render "noaccess"
        }
        format.iframe { render "noaccess" }
        format.json { render :json => {:error => "record not found"},
          :status => :unprocessable_entity}
      end
    else
      respond_to do |format|
        format.html {
          redirect_to new_user_session_path, :message => "You might have access to that post if you log in."
        }
        format.iframe { render "login" }
        format.json { render :json => {:error => "you need to login"},
          :status => :unprocessable_entity}
      end
    end
  end
  
  # GET /posts
  # GET /posts.json
  def index
    unless params[:format] == "csv"
      @posts = @posts.order('created_at DESC').page params[:page]
    end
    respond_to do |format|
      format.html {
        @sidebar = {:news => false, :posts => true}
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
    
    sharing_url_parameters = {:random_token => @post.random_token, 
      :privlyInject1 => true}
    
    if not @post.burn_after_date.nil?
      sharing_url_parameters[:random_token] = @post.random_token
    end
    
    #deprecated
    response.headers["privlyurl"] = post_url @post, sharing_url_parameters
    
    response.headers["X-Privly-Url"] = post_url @post, sharing_url_parameters
    
    @email_share = EmailShare.new
    
    respond_to do |format|
      format.html {
        
        if request.url.include? "iframe"
          sharing_url_parameters[:format] = "iframe"
          url = post_url @post, sharing_url_parameters
          redirect_to url
          return
        end
        
        @sidebar = {:post => true}
        if user_signed_in?
          @sidebar[:posts] = true
        end
        
        render
      }
      format.iframe { render }
      format.json {
        post_json = @post.as_json(:except => [:user_id, :updated_at, :public, 
          :created_at, :burn_after_date, :random_token])
        post_json.merge!(
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
    
    if user_signed_in?
      @post.burn_after_date = Time.now + 2.weeks
    else
      @post.burn_after_date = Time.now + 1.day
      @post.public = true
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @sidebar = {:markdown => true, :post => true}
  end

  # POST /posts
  # POST /posts.json
  def create
    
    @post = Post.new(params[:post])
    
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
    
    unless @post.burn_after_date
      if params[:post][:seconds_until_burn]
        seconds_until_burn = params[:post][:seconds_until_burn].to_i
        @post.burn_after_date = Time.now + seconds_until_burn.seconds
      else
        @post.burn_after_date = Time.now + 1.day
      end
    end
    
    unless params[:post][:public]
      @post.public = true
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
        
        #deprecated
        response.headers["privlyurl"] = url
        
        response.headers["X-Privly-Url"] = url
        
        format.html { redirect_to url, :notice => 'Post was successfully created.' }
        format.json { 
          post_json = @post.as_json(:callback => params[:callback])
          post_json.merge!(:privlyurl => response.headers["privlyurl"], :privlyInject1 => true)
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
  
  # If the user is logged in, CanCan handles authorization before it gets to 
  # this method. Otherwise, if the user is not logged in:
  #
  # a) User has not solved a captcha in the last 20
  # show requests, the login and captcha page is displayed for all posts.
  #
  # b) User solved the captcha but the post is not public, the login page
  # is displayed
  #
  # c) If the post is public and the user has fewer than 20 show requests,
  # display the post
  def authenticate_user_show!
    
    unless user_signed_in?  
      
      if session[:person] and session[:robot_count] >= 20
        session[:person] = false
        session[:robot_count] = 0
      elsif session[:person]
        session[:robot_count] += 1
      elsif verify_recaptcha
        session[:person] = true
        session[:robot_count] = 1
        flash[:notice] = "You are human!"
        redirect_to post_url @post, {:random_token => @post.random_token, 
          :burntAfter => @post.burn_after_date.to_i, :privlyInject1 => true}
      end
      
      if @post 
        if not session[:person] or not @post.public
          @post = nil
        end
      end
      
      unless @post
        respond_to do |format|
          format.html {
            if not session[:person] and params[:recaptcha_challenge_field]
              flash[:notice] = "You did not solve a captcha properly, are you sure you are human?"
            end
            render "login.html" 
          }
          format.iframe { 
            if not session[:person] and params[:recaptcha_challenge_field]
              flash[:notice] = "You did not solve a captcha properly, are you sure you are human?"
            end
            render "login.iframe"
          }
          format.json {
            render :json => {:error => "you need to login"}, :status => :unprocessable_entity }
        end
      end
    end
  end
  
end
