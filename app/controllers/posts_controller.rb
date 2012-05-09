class PostsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:show]
  
  load_and_authorize_resource :except => [:destroy_all]
  
  before_filter :authenticate_user_show!, :only => [:show]
  before_filter :redirect_bot, :only => :show
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    if user_signed_in?
      respond_to do |format|
        format.html {
          @sidebar = {:news => false, :posts => true}
          render "noaccess"
        }
        format.markdown { render "noaccess"  }
        format.iframe { render "noaccess" }
        format.json { render "noaccess" }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to new_user_session_path, :message => "You might have access to that post if you log in."
        }
        format.markdown { render "login"  }
        format.iframe { render "login" }
        format.json { render "login" }
      end
    end
  end
  
  # GET /posts
  # GET /posts.json
  def index
    unless params[:format] == "csv"
      @posts = @posts.page(params[:page]).order('created_at DESC')
    end
    respond_to do |format|
      format.html {
        @sidebar = {:news => false, :posts => true}
        render
      } # index.html.erb
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
    
    response.headers["privlyurl"] = request.url
    
    @email_share = EmailShare.new
    respond_to do |format|
      format.html {
        if extension_available? and not has_extension?
          if chrome_browser?
            @sidebar = {:post => true, :news => false, :posts => true, :download_extension => true, :download_chrome_extension => true}
          else
            @sidebar = {:post => true, :news => false, :posts => true, :download_extension => true}
          end
        else
          @sidebar = {:post => true, :news => false, :posts => true, :download_extension => false}
        end
        
        render
      }
      format.markdown { render }
      format.iframe { render }
      format.json { render :json => @post.to_json(:except => [:user_id, :updated_at, :public, :created_at, :burn_after_date]), :callback => params[:callback] }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @sidebar = {:markdown => true, :posts => true, :news => false}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @sidebar = {:markdown => true, :post => true, :news => false}
  end

  # POST /posts
  # POST /posts.json
  def create
    
    @post = Post.new(params[:post])
    
    if current_user
      @post.user = current_user
    end
    
    respond_to do |format|
      if @post.save
        response.headers["privlyurl"] = post_url @post
        format.html { redirect_to @post, :notice => 'Post was successfully created.' }
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
    
    unless can? :destroy, @post
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
          format.markdown { render "login.markdown" }
          format.iframe { 
            if not session[:person] and params[:recaptcha_challenge_field]
              flash[:notice] = "You did not solve a captcha properly, are you sure you are human?"
            end
            render "login.iframe" 
          }
          format.json { render :json => {:error => "you need to login"}, :status => :unprocessable_entity }
        end
      end
    end
  end
  
end
